import 'package:json_annotation/json_annotation.dart';

part 'symbol_theme_dto.g.dart';

@JsonSerializable()
class SymbolThemeDto {
  const SymbolThemeDto({
    required this.symbol,
    required this.themeId,
    required this.weight,
  });

  factory SymbolThemeDto.fromJson(Map<String, dynamic> json) =>
      _$SymbolThemeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SymbolThemeDtoToJson(this);

  final String symbol;
  @JsonKey(name: 'theme_id')
  final String themeId;
  @JsonKey(fromJson: _numFromJson)
  final num weight;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
