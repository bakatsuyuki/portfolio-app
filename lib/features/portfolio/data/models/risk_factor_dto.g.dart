// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_factor_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RiskFactorDto _$RiskFactorDtoFromJson(Map<String, dynamic> json) =>
    RiskFactorDto(
      riskId: json['risk_id'] as String,
      riskName: json['risk_name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$RiskFactorDtoToJson(RiskFactorDto instance) =>
    <String, dynamic>{
      'risk_id': instance.riskId,
      'risk_name': instance.riskName,
      'description': instance.description,
    };
