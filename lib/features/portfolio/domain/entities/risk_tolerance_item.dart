/// リスク耐性1件のドメインエンティティ。
class RiskToleranceItem {
  const RiskToleranceItem({
    required this.riskName,
    required this.tolerance,
  });

  final String riskName;
  final num tolerance;
}
