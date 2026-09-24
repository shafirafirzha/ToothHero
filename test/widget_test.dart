import 'package:flutter_test/flutter_test.dart';
import 'package:toothhero/main.dart';

void main() {
  testWidgets('ToothHero app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToothHeroApp());
  });
}
