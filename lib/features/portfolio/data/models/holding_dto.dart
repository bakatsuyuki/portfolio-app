import 'package:json_annotation/json_annotation.dart';

part 'holding_dto.g.dart';

@JsonSerializable()
class HoldingDto {
  const HoldingDto({
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.currency,
    required this.valueUsd,
    required this.valueJpy,
    required this.ratio,
  });

  factory HoldingDto.fromJson(Map<String, dynamic> json) =>
      _$HoldingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$HoldingDtoToJson(this);

  final String symbol;
  @JsonKey(fromJson: _numFromJson)
  final num quantity;
  @JsonKey(fromJson: _numFromJson)
  final num price;
  final String currency;
  @JsonKey(name: 'value_usd', fromJson: _numFromJson)
  final num valueUsd;
  @JsonKey(name: 'value_jpy', fromJson: _numFromJson)
  final num valueJpy;
  @JsonKey(fromJson: _numFromJson)
  final num ratio;

  static num _numFromJson(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}
