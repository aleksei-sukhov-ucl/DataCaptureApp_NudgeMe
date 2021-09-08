import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge_me/shared/circle_progress.dart';

void main() {
  // This part mitigates Widget test failing with No MediaQuery widget found
  Widget createWidgetForTesting({Widget child}) {
    return MaterialApp(home: child);
  }

  testWidgets('Circle Percent Indicator displays all the input provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: CirclePercentIndicator(
      color: Colors.blueAccent,
      score: 1000,
      goal: 10000,
      units: "Steps",
    )));
    await tester.pumpAndSettle();

    // Finding Color
    final circlePercentIndicatorColorFinder = tester
        .widget<CirclePercentIndicator>(find.byType(CirclePercentIndicator));
    // Finding count
    final scoreFinder = find.text('1000');
    // Finding uints
    final unitsFinder = find.text('Steps');
    expect(circlePercentIndicatorColorFinder.color, Colors.blueAccent);
    expect(scoreFinder, findsOneWidget);
    expect(unitsFinder, findsOneWidget);
  });

  testWidgets('Circle Percent Indicator not input provided',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(createWidgetForTesting(child: CirclePercentIndicator()));
    await tester.pumpAndSettle();

    // Finding Color
    final circlePercentIndicatorColorFinder = tester
        .widget<CirclePercentIndicator>(find.byType(CirclePercentIndicator));
    // Finding count
    final scoreFinder = find.text('N/A');
    expect(circlePercentIndicatorColorFinder.color, Colors.deepOrangeAccent);
    expect(scoreFinder, findsOneWidget);
  });
}
