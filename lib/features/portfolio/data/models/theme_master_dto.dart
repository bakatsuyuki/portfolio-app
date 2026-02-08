import 'package:json_annotation/json_annotation.dart';

part 'theme_master_dto.g.dart';

@JsonSerializable()
class ThemeMasterDto {
  const ThemeMasterDto({
    required this.themeId,
    required this.themeName,
    required this.description,
  });

  factory ThemeMasterDto.fromJson(Map<String, dynamic> json) =>
      _$ThemeMasterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ThemeMasterDtoToJson(this);

  @JsonKey(name: 'theme_id')
  final String themeId;
  @JsonKey(name: 'theme_name')
  final String themeName;
  final String description;
}
