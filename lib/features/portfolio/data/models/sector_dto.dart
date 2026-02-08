import 'package:json_annotation/json_annotation.dart';

part 'sector_dto.g.dart';

@JsonSerializable()
class SectorDto {
  const SectorDto({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.industry,
  });

  factory SectorDto.fromJson(Map<String, dynamic> json) =>
      _$SectorDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SectorDtoToJson(this);

  final String symbol;
  final String name;
  final String sector;
  final String industry;
}
