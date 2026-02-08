/// アプリ全体で使う定数。
class AppConstants {
  AppConstants._();

  static const String appName = 'Portfolio';

  /// Drive から取得するデータファイル名。
  static const String appDataFileName = 'app_data.json';

  /// Google OAuth 2.0 の Web クライアント ID（JSON の client_id）。
  /// client_secret はアプリに含めない。
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '284207367525-6s111lgekl8ofevoigs157lcuqoni39a.apps.googleusercontent.com',
  );
}
