import 'package:flutter_test/flutter_test.dart';

import 'package:android_tools/main.dart';

void main() {
  testWidgets('Android tools smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AndroidToolsApp());
    await tester.pumpAndSettle();

    expect(find.text('Android 签名工具'), findsOneWidget);
    expect(find.text('APK'), findsOneWidget);
    expect(find.text('AAB'), findsOneWidget);
    expect(find.text('开始签名'), findsOneWidget);
  });
}
