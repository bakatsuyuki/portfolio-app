import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/portfolio/presentation/providers/portfolio_providers.dart';
import 'routes/app_router.dart';

/// アプリのルートウィジェット。
/// ProviderScope で Riverpod を有効化し、MaterialApp.router で go_router とテーマを適用する。
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _AppLifecycleRefresher(
        child: MaterialApp.router(
          title: 'Portfolio',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}

/// アプリがフォアグラウンドに戻ったときにポートフォリオデータを再取得する。
class _AppLifecycleRefresher extends ConsumerStatefulWidget {
  const _AppLifecycleRefresher({required this.child});

  final Widget child;

  @override
  ConsumerState<_AppLifecycleRefresher> createState() =>
      _AppLifecycleRefresherState();
}

class _AppLifecycleRefresherState extends ConsumerState<_AppLifecycleRefresher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(portfolioDataProvider);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
