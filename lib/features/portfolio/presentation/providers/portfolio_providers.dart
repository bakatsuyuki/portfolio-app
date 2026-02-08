import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/app_providers.dart';
import '../../domain/entities/app_data.dart';

/// ポートフォリオデータ（app_data.json）の FutureProvider。
/// フォルダ未選択時は [DataNotFoundException] で error になる。
/// 取得後に価格履歴を差分で更新する。
final portfolioDataProvider = FutureProvider.autoDispose<AppData>((ref) async {
  final repository = await ref.watch(portfolioRepositoryProvider.future);
  final appData = await repository.getAppData();
  final priceHistoryService =
      await ref.read(priceHistoryServiceProvider.future);
  await priceHistoryService.updateFromHoldings(appData.holdings);
  ref.invalidate(priceHistoryMapProvider);
  return appData;
});
