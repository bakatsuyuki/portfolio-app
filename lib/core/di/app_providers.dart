import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../features/portfolio/data/datasources/drive_portfolio_datasource.dart';
import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../shared/models/price_history_entry.dart';
import '../../shared/services/price_history_service.dart';
import '../../shared/services/settings_service.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final settingsServiceProvider = FutureProvider<SettingsService>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsService(prefs);
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: <String>[drive.DriveApi.driveReadonlyScope],
    serverClientId: AppConstants.googleClientId.isEmpty
        ? null
        : AppConstants.googleClientId,
  );
});

/// 現在の Google サインインユーザー。サインイン/アウトで更新される。
/// 初回評価時に [GoogleSignIn.signInSilently] でキャッシュを復元する（再起動後もサインイン状態を維持するため）。
final currentUserProvider = StreamProvider<GoogleSignInAccount?>((ref) async* {
  final googleSignIn = ref.watch(googleSignInProvider);
  debugPrint(
      '[currentUserProvider] before signInSilently currentUser=${googleSignIn.currentUser?.email ?? "null"}');
  await googleSignIn.signInSilently();
  debugPrint(
      '[currentUserProvider] after signInSilently currentUser=${googleSignIn.currentUser?.email ?? "null"}');
  yield googleSignIn.currentUser;
  yield* googleSignIn.onCurrentUserChanged.map((account) {
    debugPrint(
        '[currentUserProvider] onCurrentUserChanged => ${account?.email ?? "null"}');
    return account;
  });
});

final drivePortfolioDatasourceProvider =
    Provider<DrivePortfolioDatasource>((ref) {
  final googleSignIn = ref.watch(googleSignInProvider);
  return DrivePortfolioDatasource(googleSignIn: googleSignIn);
});

final portfolioRepositoryProvider =
    FutureProvider<PortfolioRepository>((ref) async {
  final datasource = ref.watch(drivePortfolioDatasourceProvider);
  final settings = await ref.watch(settingsServiceProvider.future);
  return PortfolioRepositoryImpl(
    datasource: datasource,
    settingsService: settings,
  );
});

final priceHistoryServiceProvider =
    FutureProvider<PriceHistoryService>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return PriceHistoryService(dir.path);
});

/// 価格履歴（symbol → 時系列）。取得後に [portfolioDataProvider] が更新されると差分で追記される。
final priceHistoryMapProvider =
    FutureProvider.autoDispose<Map<String, List<PriceHistoryEntry>>>(
        (ref) async {
  final service = await ref.watch(priceHistoryServiceProvider.future);
  return service.load();
});
