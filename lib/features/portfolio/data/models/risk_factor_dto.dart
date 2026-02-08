import 'package:json_annotation/json_annotation.dart';

part 'risk_factor_dto.g.dart';

@JsonSerializable()
class RiskFactorDto {
  const RiskFactorDto({
    required this.riskId,
    required this.riskName,
    required this.description,
  });

  factory RiskFactorDto.fromJson(Map<String, dynamic> json) =>
      _$RiskFactorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RiskFactorDtoToJson(this);

  @JsonKey(name: 'risk_id')
  final String riskId;
  @JsonKey(name: 'risk_name')
  final String riskName;
  final String description;
}
