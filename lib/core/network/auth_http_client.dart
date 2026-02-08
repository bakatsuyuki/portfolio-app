import 'package:http/http.dart' as http;

/// リクエストごとに認証ヘッダーを付与する [http.Client]。
/// Google Sign-In の [GoogleSignInAccount.authHeaders] を渡して Drive API 等に利用する。
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient(this._getHeaders, [http.Client? base])
      : _client = base ?? http.Client();

  final Future<Map<String, String>> Function() _getHeaders;
  final http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _getHeaders();
    request.headers.addAll(headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}
