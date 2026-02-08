// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_region_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolRegionDto _$SymbolRegionDtoFromJson(Map<String, dynamic> json) =>
    SymbolRegionDto(
      symbol: json['symbol'] as String,
      northAmerica: SymbolRegionDto._numFromJson(json['north_america']),
      europe: SymbolRegionDto._numFromJson(json['europe']),
      asia: SymbolRegionDto._numFromJson(json['asia']),
      china: SymbolRegionDto._numFromJson(json['china']),
      other: SymbolRegionDto._numFromJson(json['other']),
    );

Map<String, dynamic> _$SymbolRegionDtoToJson(SymbolRegionDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'north_america': instance.northAmerica,
      'europe': instance.europe,
      'asia': instance.asia,
      'china': instance.china,
      'other': instance.other,
    };
