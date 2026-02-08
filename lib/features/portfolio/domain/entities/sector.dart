/// 銘柄のセクター情報のドメインエンティティ。
class Sector {
  const Sector({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.industry,
  });

  final String symbol;
  final String name;
  final String sector;
  final String industry;
}
