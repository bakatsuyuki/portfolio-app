// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_risk_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeRiskDto _$ThemeRiskDtoFromJson(Map<String, dynamic> json) => ThemeRiskDto(
      themeId: json['theme_id'] as String,
      riskId: json['risk_id'] as String,
      tolerance: ThemeRiskDto._intFromJson(json['tolerance']),
    );

Map<String, dynamic> _$ThemeRiskDtoToJson(ThemeRiskDto instance) =>
    <String, dynamic>{
      'theme_id': instance.themeId,
      'risk_id': instance.riskId,
      'tolerance': instance.tolerance,
    };
