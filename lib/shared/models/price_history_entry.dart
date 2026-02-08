/// 価格履歴の1件。差分のみ永続化するため「価格が変わった時点」の記録。
class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.timestampMs,
    required this.price,
  });

  /// 記録日時（UTC ミリ秒）。
  final int timestampMs;

  /// その時点の価格。
  final num price;

  Map<String, dynamic> toJson() => <String, dynamic>{
        't': timestampMs,
        'p': price,
      };

  static PriceHistoryEntry fromJson(Map<String, dynamic> json) {
    return PriceHistoryEntry(
      timestampMs: json['t'] as int,
      price: (json['p'] as num).toDouble(),
    );
  }
}
