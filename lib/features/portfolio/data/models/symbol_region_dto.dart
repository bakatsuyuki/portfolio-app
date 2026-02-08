import 'package:json_annotation/json_annotation.dart';

part 'symbol_region_dto.g.dart';

@JsonSerializable()
class SymbolRegionDto {
  const SymbolRegionDto({
    required this.symbol,
    required this.northAmerica,
    required this.europe,
    required this.asia,
    required this.china,
    required this.other,
  });

  factory SymbolRegionDto.fromJson(Map<String, dynamic> json) =>
      _$SymbolRegionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SymbolRegionDtoToJson(this);

  final String symbol;
  @JsonKey(name: 'north_america', fromJson: _numFromJson)
  final num northAmerica;
  @JsonKey(fromJson: _numFromJson)
  final num europe;
  @JsonKey(fromJson: _numFromJson)
  final num asia;
  @JsonKey(fromJson: _numFromJson)
  final num china;
  @JsonKey(fromJson: _numFromJson)
  final num other;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
