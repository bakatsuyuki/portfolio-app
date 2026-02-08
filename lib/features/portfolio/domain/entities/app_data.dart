import 'holding.dart';
import 'risk_tolerance_item.dart';
import 'sector.dart';
import 'theme_exposure_item.dart';

/// app_data.json に対応するドメインエンティティ。
/// プレゼン層はこの型を参照する。
class AppData {
  const AppData({
    required this.holdings,
    required this.sectors,
    required this.sectorAllocation,
    required this.themeExposure,
    required this.regionExposure,
    required this.riskTolerance,
  });

  final List<Holding> holdings;
  final List<Sector> sectors;
  final Map<String, num> sectorAllocation;
  final Map<String, ThemeExposureItem> themeExposure;
  final Map<String, num> regionExposure;
  final Map<String, RiskToleranceItem> riskTolerance;
}
