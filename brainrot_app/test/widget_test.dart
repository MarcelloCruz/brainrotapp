import 'package:flutter_test/flutter_test.dart';
import 'package:brainrot_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DopamineTaxApp());

    // Verify that our dashboard screen is displayed.
    expect(find.text('Dopamine Tax Dashboard'), findsOneWidget);
  });
}
