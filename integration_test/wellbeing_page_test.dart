import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/wellbeing_page/wellbeing_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test/widget_test.dart';

final int numberOfCard = 5;
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  // simulate the way flutter actually responds to animations
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group("All the cards on the wellbeing page load correctly", () {
    final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);
    SharedPreferences.setMockInitialValues({PREV_PEDOMETER_PAIR_KEY: 0});
    testWidgets("Wellbeing page loads correctly", (WidgetTester tester) async {
      final mockedUserWellbeingDB = MockedUserWellbeingDB();

      when(mockedUserWellbeingDB.getLastNDaysAvailable(any))
          .thenAnswer((_) async => [
                WellbeingItem(
                    date: '2021-08-26',
                    postcode: "E7",
                    wellbeingScore: 10.0,
                    numSteps: 8888,
                    sputumColour: 4.0,
                    mrcDyspnoeaScale: 1.0,
                    speechRate: 0,
                    speechRateTest: 0,
                    testDuration: 30,
                    audioURL: 'unit_test_audio',
                    supportCode: 'self_help')
              ]);

      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();
      // Check the title is loaded correctly
      expect(find.text('NudgeMe'), findsOneWidget);
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
    final mockedUserWellbeingDB = MockedUserWellbeingDB();
    final Stream<int> fakeStepStream = Stream<int>.fromIterable([7777]);
    SharedPreferences.setMockInitialValues({PREV_PEDOMETER_PAIR_KEY: 0});

    when(mockedUserWellbeingDB.getLastNDaysAvailable(any))
        .thenAnswer((_) async => [
              WellbeingItem(
                  date: '2021-08-26',
                  postcode: "E7",
                  wellbeingScore: 10.0,
                  numSteps: 8888,
                  sputumColour: 4.0,
                  mrcDyspnoeaScale: 0.0,
                  speechRate: 0,
                  speechRateTest: 0,
                  testDuration: 30,
                  audioURL: 'unit_test_audio',
                  supportCode: 'self_help')
            ]);

    testWidgets("Test Wellbeing Score Card", (WidgetTester tester) async {
      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      //Check that the header of the card load correctly
      var textFind = find.text("Wellbeing Score");
      expect(textFind, findsOneWidget);
      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.byType(WellbeingCircle), findsNWidgets(2));
      expect(find.text("10"), findsOneWidget);
    });

    testWidgets("Test Sputum Color Card", (WidgetTester tester) async {
      await tester.pumpWidget(wrapAppProvider(
          WellbeingPage(cards: cards, currentStepValueStream: fakeStepStream),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      //Check that the header of the card load correctly
      expect(find.text('Sputum colour'), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_satisfied_alt), findsOneWidget);
      expect(find.byType(WellbeingCircle), findsNWidgets(2));
      expect(find.text("4"), findsOneWidget);
    });
  });
}

void wellbeingPageIntegrationTest() {
  main();
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
