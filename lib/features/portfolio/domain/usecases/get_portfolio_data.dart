import '../entities/app_data.dart';
import '../repositories/portfolio_repository.dart';

/// ポートフォリオデータ取得ユースケース。
/// リポジトリを呼び、プレゼン層に [AppData] を渡す。
class GetPortfolioData {
  GetPortfolioData(this._repository);

  final PortfolioRepository _repository;

  /// app_data を取得する。失敗時は [Exception] を投げる。
  Future<AppData> call() => _repository.getAppData();
}
