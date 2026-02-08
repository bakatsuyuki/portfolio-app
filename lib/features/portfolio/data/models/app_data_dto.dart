import 'package:json_annotation/json_annotation.dart';

import 'holding_dto.dart';
import 'risk_factor_dto.dart';
import 'sector_dto.dart';
import 'symbol_region_dto.dart';
import 'symbol_theme_dto.dart';
import 'theme_master_dto.dart';
import 'theme_risk_dto.dart';

part 'app_data_dto.g.dart';

@JsonSerializable()
class AppDataDto {
  const AppDataDto({
    required this.holdings,
    required this.sectors,
    required this.symbolThemes,
    required this.themesMaster,
    required this.symbolRegions,
    required this.riskFactors,
    required this.themeRisks,
    required this.sectorAllocation,
    required this.themeExposure,
    required this.regionExposure,
    required this.riskTolerance,
  });

  factory AppDataDto.fromJson(Map<String, dynamic> json) =>
      _$AppDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AppDataDtoToJson(this);

  final List<HoldingDto> holdings;
  final List<SectorDto> sectors;
  @JsonKey(name: 'symbol_themes')
  final List<SymbolThemeDto> symbolThemes;
  @JsonKey(name: 'themes_master')
  final List<ThemeMasterDto> themesMaster;
  @JsonKey(name: 'symbol_regions')
  final List<SymbolRegionDto> symbolRegions;
  @JsonKey(name: 'risk_factors')
  final List<RiskFactorDto> riskFactors;
  @JsonKey(name: 'theme_risks')
  final List<ThemeRiskDto> themeRisks;
  @JsonKey(name: 'sector_allocation')
  final Map<String, SectorAllocationItemDto> sectorAllocation;
  @JsonKey(name: 'theme_exposure')
  final Map<String, ThemeExposureItemDto> themeExposure;
  @JsonKey(name: 'region_exposure')
  final Map<String, num> regionExposure;
  @JsonKey(name: 'risk_tolerance')
  final Map<String, RiskToleranceItemDto> riskTolerance;
}

@JsonSerializable()
class SectorAllocationItemDto {
  const SectorAllocationItemDto({required this.ratio});

  factory SectorAllocationItemDto.fromJson(Map<String, dynamic> json) =>
      _$SectorAllocationItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SectorAllocationItemDtoToJson(this);

  @JsonKey(fromJson: _numFromJson)
  final num ratio;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class ThemeExposureItemDto {
  const ThemeExposureItemDto({
    required this.themeName,
    required this.ratio,
    required this.contributors,
  });

  factory ThemeExposureItemDto.fromJson(Map<String, dynamic> json) =>
      _$ThemeExposureItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeExposureItemDtoToJson(this);

  @JsonKey(name: 'theme_name')
  final String themeName;
  @JsonKey(fromJson: _numFromJson)
  final num ratio;
  final String contributors;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class RiskToleranceItemDto {
  const RiskToleranceItemDto({
    required this.riskName,
    required this.tolerance,
  });

  factory RiskToleranceItemDto.fromJson(Map<String, dynamic> json) =>
      _$RiskToleranceItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RiskToleranceItemDtoToJson(this);

  @JsonKey(name: 'risk_name')
  final String riskName;
  @JsonKey(fromJson: _numFromJson)
  final num tolerance;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
