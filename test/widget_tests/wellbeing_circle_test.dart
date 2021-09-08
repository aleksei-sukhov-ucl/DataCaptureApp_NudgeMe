import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';

void main() {
  // This part mitigates Widget test failing with No MediaQuery widget found
  Widget createWidgetForTesting({Widget child}) {
    return MaterialApp(home: child);
  }

  testWidgets('WellbeingCircle displays N/A if no input provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(child: WellbeingCircle()));
    await tester.pumpAndSettle();

    final scoreFinder = find.text('N/A');
    expect(scoreFinder, findsOneWidget);
  });

  testWidgets('WellbeingCircle displays score', (WidgetTester tester) async {
    await tester
        .pumpWidget(createWidgetForTesting(child: WellbeingCircle(score: 7)));
    await tester.pumpAndSettle();

    final scoreFinder = find.text('7');
    expect(scoreFinder, findsOneWidget);
  });

  testWidgets('WellbeingCircle displays N/A if null',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        createWidgetForTesting(child: WellbeingCircle(score: null)));
    await tester.pumpAndSettle();

    final scoreFinder = find.text('N/A');
    expect(scoreFinder, findsOneWidget);
  });

  testWidgets(
      'WellbeingCircle falls back to default colors of firstColor: '
      'purple and secondColor: blue', (WidgetTester tester) async {
    await tester
        .pumpWidget(createWidgetForTesting(child: WellbeingCircle(score: 5)));
    await tester.pumpAndSettle();

    final wellbeingCircleColorFinder =
        tester.widget<WellbeingCircle>(find.byType(WellbeingCircle));
    expect(wellbeingCircleColorFinder.firstColor, Colors.purpleAccent);
    expect(wellbeingCircleColorFinder.secondColor, Colors.blueAccent);
  });
}
