import 'dart:convert';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/app_data.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/risk_tolerance_item.dart';
import '../../domain/entities/sector.dart';
import '../../domain/entities/theme_exposure_item.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/drive_portfolio_datasource.dart';
import '../models/app_data_dto.dart';
import '../models/holding_dto.dart';
import '../models/sector_dto.dart';
import '../../../../shared/services/settings_service.dart';

/// ポートフォリオリポジトリの Drive 実装。
/// フォルダ ID は [SettingsService] から取得する。
class PortfolioRepositoryImpl implements PortfolioRepository {
  PortfolioRepositoryImpl({
    required DrivePortfolioDatasource datasource,
    required SettingsService settingsService,
  })  : _datasource = datasource,
        _settingsService = settingsService;

  final DrivePortfolioDatasource _datasource;
  final SettingsService _settingsService;

  @override
  Future<AppData> getAppData() async {
    final folderId = _settingsService.driveFolderId;
    if (folderId == null || folderId.isEmpty) {
      throw const DataNotFoundException(
        'Drive フォルダが選択されていません。設定でフォルダを選択してください。',
      );
    }

    final jsonString = await _datasource.getAppDataJson(folderId);
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final dto = AppDataDto.fromJson(json);
    return _mapToAppData(dto);
  }

  static AppData _mapToAppData(AppDataDto dto) {
    return AppData(
      holdings: dto.holdings.map(_mapHolding).toList(),
      sectors: dto.sectors.map(_mapSector).toList(),
      sectorAllocation: dto.sectorAllocation.map(
        (k, v) => MapEntry(k, v.ratio),
      ),
      themeExposure: dto.themeExposure.map(
        (k, v) => MapEntry(
            k,
            ThemeExposureItem(
                themeName: v.themeName,
                ratio: v.ratio,
                contributors: v.contributors)),
      ),
      regionExposure: dto.regionExposure,
      riskTolerance: dto.riskTolerance.map(
        (k, v) => MapEntry(
            k, RiskToleranceItem(riskName: v.riskName, tolerance: v.tolerance)),
      ),
    );
  }

  static Holding _mapHolding(HoldingDto d) {
    return Holding(
      symbol: d.symbol,
      quantity: d.quantity,
      price: d.price,
      currency: d.currency,
      valueUsd: d.valueUsd,
      valueJpy: d.valueJpy,
      ratio: d.ratio,
    );
  }

  static Sector _mapSector(SectorDto d) {
    return Sector(
      symbol: d.symbol,
      name: d.name,
      sector: d.sector,
      industry: d.industry,
    );
  }
}
