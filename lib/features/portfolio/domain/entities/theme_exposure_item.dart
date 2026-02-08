/// テーマエクスポージャー1件のドメインエンティティ。
class ThemeExposureItem {
  const ThemeExposureItem({
    required this.themeName,
    required this.ratio,
    required this.contributors,
  });

  final String themeName;
  final num ratio;
  final String contributors;
}
