import 'package:flutter_test/flutter_test.dart';

import 'package:android_tools/main.dart';

void main() {
  testWidgets('TDesign home page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AndroidToolsApp());
    await tester.pumpAndSettle();

    expect(find.text('AndroidTools'), findsWidgets);
    expect(find.text('TDesign Flutter 已接入'), findsOneWidget);
    expect(find.text('开始构建 AndroidTools'), findsOneWidget);
  });
}
