import 'package:flutter_test/flutter_test.dart';

import 'package:portfolio_app/app.dart';

void main() {
  testWidgets('App shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Welcome to Portfolio App'), findsOneWidget);
  });
}
