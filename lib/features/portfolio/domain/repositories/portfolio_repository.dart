import '../entities/app_data.dart';

/// ポートフォリオデータ取得の抽象リポジトリ。
/// 実装は data 層に置く（Drive 等）。
abstract interface class PortfolioRepository {
  /// app_data.json の内容を取得する。
  /// 失敗時は [Exception] を投げる（呼び出し元で Result に包んでもよい）。
  Future<AppData> getAppData();
}
