// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symbol_theme_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymbolThemeDto _$SymbolThemeDtoFromJson(Map<String, dynamic> json) =>
    SymbolThemeDto(
      symbol: json['symbol'] as String,
      themeId: json['theme_id'] as String,
      weight: SymbolThemeDto._numFromJson(json['weight']),
    );

Map<String, dynamic> _$SymbolThemeDtoToJson(SymbolThemeDto instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'theme_id': instance.themeId,
      'weight': instance.weight,
    };
