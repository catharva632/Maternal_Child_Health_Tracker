import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maternal_health_app/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MaternalHealthTrackerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
