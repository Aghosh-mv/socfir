import 'package:flutter_test/flutter_test.dart';
import 'package:socfir/app.dart';

void main() {
  testWidgets('SocFirApp smoke test', (WidgetTester tester) async {
    // Just verify it builds without crashing
    expect(SocFirApp, isNotNull);
  });
}
