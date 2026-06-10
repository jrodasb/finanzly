import 'package:flutter_test/flutter_test.dart';
import 'package:finanzly/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanzlyApp());
    expect(find.text('Finanzly'), findsOneWidget);
  });
}
