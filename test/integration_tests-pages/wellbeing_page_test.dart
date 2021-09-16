import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/wellbeing_page/trends_tile.dart';
import 'package:nudge_me/pages/wellbeing_page/wellbeing_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/shared/circle_progress.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_test.dart';

/// In case additional cards are added, change numberOfCard
final int numberOfCard = 5;
void main() {
  final mockedUserWellbeingDB = MockedUserWellbeingDB();
  SharedPreferences.setMockInitialValues({
    PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
  });

  WellbeingItem wellbeingItem = WellbeingItem(
      date: '2021-08-26',
      postcode: "E7",
      wellbeingScore: 10,
      numSteps: 8888,
      sputumColour: 4,
      mrcDyspnoeaScale: 0.0,
      speechRate: 0,
      speechRateTest: 0,
      testDuration: 30,
      audioURL: 'unit_test_audio',
      supportCode: 'self_help');

  when(mockedUserWellbeingDB.getLastNDaysAvailable(any))
      .thenAnswer((_) async => [wellbeingItem]);

  group("All the cards on the wellbeing page load correctly", () {
    testWidgets("Wellbeing page loads correctly", (WidgetTester tester) async {
      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(
              cards: cards,
              currentStepValueStream:
                  Pedometer.stepCountStream.map((event) => event.steps)),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      // Check the title is loaded correctly
      expect(find.text('NudgeShare'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      //Check that all cards loaded correctly
      expect(find.text('View More'), findsNWidgets(numberOfCard));
      expect(find.byType(Card), findsNWidgets(numberOfCard));

      //Check that correct cards are loaded correctly
      expect(find.text('Steps'), findsOneWidget);
      expect(find.text('Wellbeing Score'), findsOneWidget);
      expect(find.text('Sputum colour'), findsOneWidget);
      expect(find.text('MRC Dyspnoea Scale'), findsOneWidget);
      expect(find.text('Trends'), findsOneWidget);
    });
  });

  group("Testing Every Card Individually", () {
    testWidgets("Steps Card Test - Emulator", (WidgetTester tester) async {
      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(
              currentStepValueStream: Stream.castFrom(
                  Pedometer.stepCountStream.map((event) => event.steps)),
              cards: cards),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      // Check the title is loaded correctly
      expect(find.text('Steps'), findsOneWidget);
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      // //Find a steps card
      final parentFinder = find.ancestor(
          of: find.byIcon(Icons.directions_walk), matching: find.byType(Card));

      //Find a child i.e. CircularPercentIndicator in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(CircularPercentIndicator));
      expect(childFinder, findsOneWidget);

      final stepCount =
          find.descendant(of: childFinder, matching: find.text("N/A"));
      expect(stepCount, findsOneWidget);
    });

    testWidgets("Steps Card Test - real device", (WidgetTester tester) async {
      final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(currentStepValueStream: fakeStepStream, cards: cards),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      // Check the title is loaded correctly
      expect(find.text('Steps'), findsNWidgets(2));
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      // //Find a steps card
      final parentFinder = find.ancestor(
          of: find.byIcon(Icons.directions_walk), matching: find.byType(Card));

      //Find a child i.e. CircularPercentIndicator in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(CircularPercentIndicator));
      expect(childFinder, findsOneWidget);

      final stepCount =
          find.descendant(of: childFinder, matching: find.text("7777"));
      expect(stepCount, findsOneWidget);
    });

    testWidgets("Test Wellbeing Card", (WidgetTester tester) async {
      final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      final iconToFind = Icons.accessibility_new;
      //Find a Wellbeing card
      final parentFinder = find.ancestor(
          of: find.byIcon(iconToFind), matching: find.byType(Card));

      //Check that the header of the card load correctly
      //Correct Title
      final wellbeingScoreHeaderFinder = find.descendant(
          of: parentFinder, matching: find.text("Wellbeing Score"));
      expect(wellbeingScoreHeaderFinder, findsOneWidget);
      //Correct Icon
      final wellbeingScoreHeaderIconFinder =
          find.descendant(of: parentFinder, matching: find.byIcon(iconToFind));
      expect(wellbeingScoreHeaderIconFinder, findsOneWidget);

      //Find a child i.e. WellbeingCircle in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(WellbeingCircle));
      expect(childFinder, findsOneWidget);

      //Assess the Wellbeing Circle
      //Find Wellbeing Score
      final wellbeingScoreFinder = find.descendant(
          of: childFinder,
          matching: find.text(wellbeingItem.wellbeingScore.toInt().toString()));
      expect(wellbeingScoreFinder, findsOneWidget);
    });

    testWidgets("Test Sputum colour Card", (WidgetTester tester) async {
      final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      final iconToFind = Icons.sentiment_satisfied_alt;
      //Find a Sputum colour card
      final parentFinder = find.ancestor(
          of: find.byIcon(iconToFind), matching: find.byType(Card));

      //Check that the header of the card load correctly
      //Correct Title
      final sputumColourHeaderFinder = find.descendant(
          of: parentFinder, matching: find.text("Sputum colour"));
      expect(sputumColourHeaderFinder, findsOneWidget);
      //Correct Icon
      final sputumColourHeaderIconFinder =
          find.descendant(of: parentFinder, matching: find.byIcon(iconToFind));
      expect(sputumColourHeaderIconFinder, findsOneWidget);

      //Find a child i.e. WellbeingCircle in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(WellbeingCircle));
      expect(childFinder, findsOneWidget);

      //Assess the Wellbeing Circle
      //Find Wellbeing Score
      final sputumColourScoreFinder = find.descendant(
          of: childFinder,
          matching: find.text(wellbeingItem.sputumColour.toInt().toString()));
      expect(sputumColourScoreFinder, findsOneWidget);
    });

    testWidgets("Test MRC Dyspnoea Scale Card", (WidgetTester tester) async {
      final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      //Find a MRC Dyspnoea Scale card
      final parentFinder = find.ancestor(
          of: find.text("MRC Dyspnoea Scale"), matching: find.byType(Card));

      //Check that the header of the card load correctly
      //Correct Title
      final headerFinder = find.descendant(
          of: parentFinder, matching: find.text("MRC Dyspnoea Scale"));
      expect(headerFinder, findsOneWidget);
      //Correct Icon
      final headerIconFinder =
          find.descendant(of: parentFinder, matching: find.byType(Image));
      expect(headerIconFinder, findsOneWidget);

      //Find a child i.e. CircularProgressIndicator in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(CirclePercentIndicator));
      expect(childFinder, findsOneWidget);

      //Assess the CircularProgressIndicator
      //Find Breathlessness Score
      final scoreFinder = find.descendant(
          of: childFinder,
          matching:
              find.text(wellbeingItem.mrcDyspnoeaScale.toInt().toString()));
      expect(scoreFinder, findsOneWidget);
    });

    testWidgets("Test Trends Card", (WidgetTester tester) async {
      final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      final iconToFind = Icons.timeline_outlined;
      //Find a Trends card
      final parentFinder = find.ancestor(
          of: find.byIcon(iconToFind), matching: find.byType(Card));

      //Check that the header of the card load correctly
      //Correct Title
      final headerFinder =
          find.descendant(of: parentFinder, matching: find.text("Trends"));
      expect(headerFinder, findsOneWidget);
      //Correct Icon
      final headerIconFinder =
          find.descendant(of: parentFinder, matching: find.byIcon(iconToFind));
      expect(headerIconFinder, findsOneWidget);

      //Find a child i.e. LineChartTile in that particular card
      final childFinder = find.descendant(
          of: parentFinder, matching: find.byType(LineChartTile));
      expect(childFinder, findsOneWidget);
    });
  });
}

class MockStream extends Mock implements Stream<int> {}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
