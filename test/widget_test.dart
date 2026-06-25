import 'package:flutter_test/flutter_test.dart';
import 'package:cashu_drops/app/app.dart';

void main() {
  testWidgets('CashuDrops App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const CashuDropsApp());
    expect(find.text('CashuDrops'), findsOneWidget);
  });
}
