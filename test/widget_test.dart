import 'package:flutter_test/flutter_test.dart';

import 'package:android_tools/main.dart';

void main() {
  testWidgets('APK signer page smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AndroidToolsApp());
    await tester.pumpAndSettle();

    expect(find.text('Android APK 签名'), findsOneWidget);
    expect(find.text('APK文件'), findsOneWidget);
    expect(find.text('输出路径'), findsOneWidget);
    expect(find.text('开始签名'), findsOneWidget);
  });
}
