import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio_app/app.dart';

void main() {
  testWidgets('App builds with bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('ポートフォリオ'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
