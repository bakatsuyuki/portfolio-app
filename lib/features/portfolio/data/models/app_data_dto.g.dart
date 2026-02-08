// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDataDto _$AppDataDtoFromJson(Map<String, dynamic> json) => AppDataDto(
      holdings: (json['holdings'] as List<dynamic>)
          .map((e) => HoldingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectors: (json['sectors'] as List<dynamic>)
          .map((e) => SectorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      symbolThemes: (json['symbol_themes'] as List<dynamic>)
          .map((e) => SymbolThemeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      themesMaster: (json['themes_master'] as List<dynamic>)
          .map((e) => ThemeMasterDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      symbolRegions: (json['symbol_regions'] as List<dynamic>)
          .map((e) => SymbolRegionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      riskFactors: (json['risk_factors'] as List<dynamic>)
          .map((e) => RiskFactorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      themeRisks: (json['theme_risks'] as List<dynamic>)
          .map((e) => ThemeRiskDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sectorAllocation: (json['sector_allocation'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, SectorAllocationItemDto.fromJson(e as Map<String, dynamic>)),
      ),
      themeExposure: (json['theme_exposure'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, ThemeExposureItemDto.fromJson(e as Map<String, dynamic>)),
      ),
      regionExposure: (json['region_exposure'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num)),
          ) ??
          {},
      riskTolerance: (json['risk_tolerance'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, RiskToleranceItemDto.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AppDataDtoToJson(AppDataDto instance) =>
    <String, dynamic>{
      'holdings': instance.holdings.map((e) => e.toJson()).toList(),
      'sectors': instance.sectors.map((e) => e.toJson()).toList(),
      'symbol_themes': instance.symbolThemes.map((e) => e.toJson()).toList(),
      'themes_master': instance.themesMaster.map((e) => e.toJson()).toList(),
      'symbol_regions': instance.symbolRegions.map((e) => e.toJson()).toList(),
      'risk_factors': instance.riskFactors.map((e) => e.toJson()).toList(),
      'theme_risks': instance.themeRisks.map((e) => e.toJson()).toList(),
      'sector_allocation':
          instance.sectorAllocation.map((k, e) => MapEntry(k, e.toJson())),
      'theme_exposure':
          instance.themeExposure.map((k, e) => MapEntry(k, e.toJson())),
      'region_exposure': instance.regionExposure,
      'risk_tolerance':
          instance.riskTolerance.map((k, e) => MapEntry(k, e.toJson())),
    };

SectorAllocationItemDto _$SectorAllocationItemDtoFromJson(
        Map<String, dynamic> json) =>
    SectorAllocationItemDto(
      ratio: SectorAllocationItemDto._numFromJson(json['ratio']),
    );

Map<String, dynamic> _$SectorAllocationItemDtoToJson(
        SectorAllocationItemDto instance) =>
    <String, dynamic>{
      'ratio': instance.ratio,
    };

ThemeExposureItemDto _$ThemeExposureItemDtoFromJson(
        Map<String, dynamic> json) =>
    ThemeExposureItemDto(
      themeName: json['theme_name'] as String,
      ratio: ThemeExposureItemDto._numFromJson(json['ratio']),
      contributors: json['contributors'] as String,
    );

Map<String, dynamic> _$ThemeExposureItemDtoToJson(
        ThemeExposureItemDto instance) =>
    <String, dynamic>{
      'theme_name': instance.themeName,
      'ratio': instance.ratio,
      'contributors': instance.contributors,
    };

RiskToleranceItemDto _$RiskToleranceItemDtoFromJson(
        Map<String, dynamic> json) =>
    RiskToleranceItemDto(
      riskName: json['risk_name'] as String,
      tolerance: RiskToleranceItemDto._numFromJson(json['tolerance']),
    );

Map<String, dynamic> _$RiskToleranceItemDtoToJson(
        RiskToleranceItemDto instance) =>
    <String, dynamic>{
      'risk_name': instance.riskName,
      'tolerance': instance.tolerance,
    };
