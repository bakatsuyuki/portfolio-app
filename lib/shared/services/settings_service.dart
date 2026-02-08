import 'package:shared_preferences/shared_preferences.dart';

/// Drive フォルダ ID などの設定を永続化するサービス。
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyDriveFolderId = 'drive_folder_id';
  static const String _keyDisplayCurrency = 'display_currency';

  /// 選択した Drive フォルダ ID。未設定なら null。
  String? get driveFolderId => _prefs.getString(_keyDriveFolderId);

  /// Drive フォルダ ID を保存する。
  Future<void> setDriveFolderId(String? folderId) async {
    if (folderId == null) {
      await _prefs.remove(_keyDriveFolderId);
    } else {
      await _prefs.setString(_keyDriveFolderId, folderId);
    }
  }

  /// 表示通貨（'USD' / 'JPY'）。未設定なら 'USD'。
  String get displayCurrency => _prefs.getString(_keyDisplayCurrency) ?? 'USD';

  /// 表示通貨を保存する。
  Future<void> setDisplayCurrency(String currency) async {
    await _prefs.setString(_keyDisplayCurrency, currency);
  }
}
