import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// ウォッチリスト画面（将来実装）。
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.darkBackgroundGradient,
        child: const SafeArea(
          child: Center(
            child: Text(
              'ウォッチリスト（準備中）',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
