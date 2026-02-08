// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sector_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectorDto _$SectorDtoFromJson(Map<String, dynamic> json) => SectorDto(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      sector: json['sector'] as String,
      industry: json['industry'] as String,
    );

Map<String, dynamic> _$SectorDtoToJson(SectorDto instance) => <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'sector': instance.sector,
      'industry': instance.industry,
    };
