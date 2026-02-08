/// アプリ固有の例外の基底。
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppException: $message${cause != null ? ' ($cause)' : ''}';
}

/// データ取得失敗（ネットワーク・Drive API 等）。
final class DataFetchException extends AppException {
  const DataFetchException(super.message, [super.cause]);
}

/// データが見つからない（フォルダ内に app_data.json がない等）。
final class DataNotFoundException extends AppException {
  const DataNotFoundException(super.message, [super.cause]);
}

/// パース失敗（JSON 不正等）。
final class ParseException extends AppException {
  const ParseException(super.message, [super.cause]);
}
