import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nihongo/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NihongoApp());

    // Verify that our app shows the welcome screen buttons.
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('이미 계정이 있습니다'), findsOneWidget);
  });
}
