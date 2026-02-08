// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_master_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThemeMasterDto _$ThemeMasterDtoFromJson(Map<String, dynamic> json) =>
    ThemeMasterDto(
      themeId: json['theme_id'] as String,
      themeName: json['theme_name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$ThemeMasterDtoToJson(ThemeMasterDto instance) =>
    <String, dynamic>{
      'theme_id': instance.themeId,
      'theme_name': instance.themeName,
      'description': instance.description,
    };
