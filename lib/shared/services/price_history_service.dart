import 'dart:convert';
import 'dart:io';

import '../models/price_history_entry.dart';
import '../../features/portfolio/domain/entities/holding.dart';

/// 価格履歴をローカルに永続化するサービス。
/// 差分のみ記録する（価格が変わった時点だけ追加）。
class PriceHistoryService {
  PriceHistoryService(this._storagePath);

  final String _storagePath;
  static const String _fileName = 'price_history.json';

  String get _filePath => '$_storagePath/$_fileName';

  /// 永続化済みの履歴を読み込む。symbol → 時系列（古い順）。
  Future<Map<String, List<PriceHistoryEntry>>> load() async {
    final file = File(_filePath);
    if (!await file.exists()) {
      return <String, List<PriceHistoryEntry>>{};
    }
    final content = await file.readAsString();
    if (content.isEmpty) {
      return <String, List<PriceHistoryEntry>>{};
    }
    final json = jsonDecode(content) as Map<String, dynamic>;
    final result = <String, List<PriceHistoryEntry>>{};
    for (final entry in json.entries) {
      final list = entry.value as List<dynamic>;
      result[entry.key] = list
          .map((e) => PriceHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return result;
  }

  /// 現在の保持データを保存する。
  Future<void> save(Map<String, List<PriceHistoryEntry>> data) async {
    final file = File(_filePath);
    final json = <String, dynamic>{};
    for (final entry in data.entries) {
      json[entry.key] = entry.value.map((e) => e.toJson()).toList();
    }
    await file.writeAsString(jsonEncode(json));
  }

  /// 取得した [holdings] をもとに履歴を更新する。価格が前回と異なる場合のみ追加（差分）。
  Future<void> updateFromHoldings(List<Holding> holdings) async {
    final data = await load();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    for (final holding in holdings) {
      final symbol = holding.symbol;
      final currentPrice = holding.price;
      final list = data[symbol] ?? <PriceHistoryEntry>[];
      final lastPrice = list.isEmpty ? null : list.last.price;

      if (lastPrice == null || lastPrice != currentPrice) {
        list.add(PriceHistoryEntry(timestampMs: now, price: currentPrice));
        data[symbol] = list;
      }
    }

    await save(data);
  }

  /// 指定銘柄の直前の価格（履歴の最後の1件の価格）。なければ null。
  Future<num?> getLastPrice(String symbol) async {
    final data = await load();
    final list = data[symbol];
    if (list == null || list.isEmpty) return null;
    return list.last.price;
  }
}
