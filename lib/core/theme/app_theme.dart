import 'package:flutter/material.dart';

/// アプリ全体のテーマ定義。
/// ダークテーマをベースに、背景グラデーション・カード半透明を適用する。
class AppTheme {
  AppTheme._();

  static const Color _darkBgStart = Color(0xFF1A1A2E);
  static const Color _darkBgEnd = Color(0xFF16213E);
  static const Color _cardSurface = Color(0x0DFFFFFF);

  /// ライトテーマ。
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }

  /// ダークテーマ（背景グラデーション・カード半透明）。
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: _darkBgStart,
    );
  }

  /// ダーク背景のグラデーション（Decoration 用）。
  static BoxDecoration get darkBackgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_darkBgStart, _darkBgEnd],
      ),
    );
  }

  /// カード用の半透明表面色。
  static Color get cardSurface => _cardSurface;
}
