import 'package:flutter_test/flutter_test.dart';

import 'package:xiayue_chat/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const XiayueChatApp());
    expect(find.text('遐悦聊天'), findsWidgets);
  });
}
