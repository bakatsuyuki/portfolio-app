import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/di/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/settings_service.dart';
import '../../../portfolio/data/datasources/drive_portfolio_datasource.dart';
import '../../../portfolio/presentation/providers/portfolio_providers.dart';

/// 設定画面（サインイン・Drive フォルダ選択・表示通貨）。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsServiceProvider);
    final googleSignIn = ref.watch(googleSignInProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser =
        currentUserAsync.whenOrNull(data: (GoogleSignInAccount? u) => u);

    return Scaffold(
      body: Container(
        decoration: AppTheme.darkBackgroundGradient,
        child: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverAppBar(
                title: Text('設定'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      if (currentUser == null) ...[
                        const Text(
                          'Google でサインインすると、Drive からポートフォリオデータを読み込めます。',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () async {
                            final account = await googleSignIn.signIn();
                            debugPrint(
                                '[SettingsScreen] signIn() returned ${account?.email ?? "null"}');
                            ref.invalidate(currentUserProvider);
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('サインイン'),
                        ),
                      ] else ...[
                        Text(
                          'サインイン中: ${currentUser.email}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () async {
                            await googleSignIn.signOut();
                            ref.invalidate(currentUserProvider);
                          },
                          child: const Text('サインアウト'),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'データフォルダ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        settingsAsync.when(
                          data: (SettingsService settings) {
                            final folderId = settings.driveFolderId;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (folderId != null)
                                  Text(
                                    '選択済み: $folderId',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 8),
                                FilledButton.icon(
                                  onPressed: () => _pickFolder(context, ref),
                                  icon: const Icon(Icons.folder_open),
                                  label: Text(
                                    folderId == null ? 'フォルダを選択' : 'フォルダを変更',
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (Object e, StackTrace _) => Text(
                            '設定の読み込みに失敗しました: $e',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final datasource = ref.read(drivePortfolioDatasourceProvider);
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<DriveFolderItem>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, ScrollController scrollController) {
            return _FolderPickerSheet(
              datasource: datasource,
              scrollController: scrollController,
            );
          },
        );
      },
    );

    if (selected == null) return;

    final settings = await ref.read(settingsServiceProvider.future);
    await settings.setDriveFolderId(selected.id);
    ref.invalidate(portfolioDataProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${selected.name}」を選択しました')),
      );
    }
  }
}

/// ネストしたフォルダを辿って選択するボトムシート用ウィジェット。
class _FolderPickerSheet extends StatefulWidget {
  const _FolderPickerSheet({
    required this.datasource,
    required this.scrollController,
  });

  final DrivePortfolioDatasource datasource;
  final ScrollController scrollController;

  @override
  State<_FolderPickerSheet> createState() => _FolderPickerSheetState();
}

class _FolderPickerSheetState extends State<_FolderPickerSheet> {
  final List<DriveFolderItem> _pathStack = <DriveFolderItem>[];
  List<DriveFolderItem> _folders = <DriveFolderItem>[];
  bool _loading = true;
  String? _error;

  String get _currentFolderId =>
      _pathStack.isEmpty ? 'root' : _pathStack.last.id;
  String get _currentFolderName =>
      _pathStack.isEmpty ? 'マイドライブ' : _pathStack.last.name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.datasource.listFolders(_currentFolderId);
      if (mounted) {
        setState(() {
          _folders = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _goUp() {
    setState(() => _pathStack.removeLast());
    _load();
  }

  void _enterFolder(DriveFolderItem folder) {
    setState(() => _pathStack.add(folder));
    _load();
  }

  void _selectCurrentFolder() {
    final item = _pathStack.isEmpty
        ? const DriveFolderItem(id: 'root', name: 'マイドライブ')
        : _pathStack.last;
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverToBoxAdapter(
          child: Text(
            'app_data.json を含むフォルダを選択',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      if (_pathStack.isNotEmpty)
        SliverToBoxAdapter(
          child: ListTile(
            leading: const Icon(Icons.arrow_upward),
            title: const Text('上へ'),
            onTap: _goUp,
          ),
        ),
      SliverToBoxAdapter(
        child: ListTile(
          leading: const Icon(Icons.folder),
          title: Text(_currentFolderName),
          subtitle: const Text('このフォルダを選択'),
          onTap: _selectCurrentFolder,
        ),
      ),
      const SliverToBoxAdapter(child: Divider(height: 1)),
    ];

    if (_loading) {
      slivers.add(
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (_error != null) {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '取得に失敗しました: $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, int i) {
              final folder = _folders[i];
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _enterFolder(folder),
              );
            },
            childCount: _folders.length,
          ),
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: slivers,
      ),
    );
  }
}
