import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:account_app/app.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AccountApp()),
    );
    expect(find.text('语音记账'), findsOneWidget);
  });
}
