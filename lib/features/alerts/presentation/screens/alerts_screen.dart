import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// アラート画面（将来実装）。
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.darkBackgroundGradient,
        child: const SafeArea(
          child: Center(
            child: Text(
              'アラート（準備中）',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
