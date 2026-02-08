import 'package:json_annotation/json_annotation.dart';

part 'theme_risk_dto.g.dart';

@JsonSerializable()
class ThemeRiskDto {
  const ThemeRiskDto({
    required this.themeId,
    required this.riskId,
    required this.tolerance,
  });

  factory ThemeRiskDto.fromJson(Map<String, dynamic> json) =>
      _$ThemeRiskDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeRiskDtoToJson(this);

  @JsonKey(name: 'theme_id')
  final String themeId;
  @JsonKey(name: 'risk_id')
  final String riskId;
  @JsonKey(fromJson: _intFromJson)
  final int tolerance;

  static int _intFromJson(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
