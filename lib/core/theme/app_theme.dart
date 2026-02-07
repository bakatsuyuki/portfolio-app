import 'package:flutter/material.dart';

/// アプリ全体のテーマ定義。
/// core/theme で一元管理し、Theme.of(context) 経由で参照する。
class AppTheme {
  AppTheme._();

  /// ライトテーマ。
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }

  /// ダークテーマ。
  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
