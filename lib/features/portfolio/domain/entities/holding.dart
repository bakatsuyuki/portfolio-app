/// 保有銘柄のドメインエンティティ。
class Holding {
  const Holding({
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.currency,
    required this.valueUsd,
    required this.valueJpy,
    required this.ratio,
  });

  final String symbol;
  final num quantity;
  final num price;
  final String currency;
  final num valueUsd;
  final num valueJpy;
  final num ratio;
}
