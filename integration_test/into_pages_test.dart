import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test/widget_test.dart';

Future<Null> _swipeThroughIntro(WidgetTester tester) async {
  //First Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Second Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Third Page
  await tester.drag(
      find.byIcon(Icons.emoji_people_rounded), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Fourth Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Fifth Page
  await tester.drag(
      find.byIcon(Icons.directions_walk_rounded), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Sixth Page
  await tester.drag(
      find.byIcon(Icons.record_voice_over_rounded), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Seventh Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Eighth Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  // simulate the way flutter actually responds to animations
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('intro screen', () {
    testWidgets('Swiping switches page', (WidgetTester tester) async {
      await tester.pumpWidget(wrapAppProvider(IntroScreen()));

      expect(find.text("Welcome"), findsOneWidget);
      await tester.drag(find.text("Welcome"), Offset(-400.0, 0.0));
      await tester.pumpAndSettle();
      expect(find.text("Welcome"), findsNothing);
    });

    testWidgets(
        'Swipes through introduction page and do not input support code or post code',
        (WidgetTester tester) async {
      // this will generate json data in the build folder
      // await binding.watchPerformance(() async {
      await tester.pumpWidget(
          wrapAppProvider(IntroScreen()), Duration(seconds: 2));

      await _swipeThroughIntro(tester);

      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();

      // did not change page:
      expect(find.text("Done"), findsOneWidget);
      // });
    });

    testWidgets(
        'Successfully completing registration, checking if correct data was submitted',
        (WidgetTester tester) async {
      final mockedUserWellbeingDB = MockedUserWellbeingDB();
      final supportCode = "GP";
      final postcode = "M11";
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(wrapAppProvider(
        IntroScreen(),
        wbDB: mockedUserWellbeingDB,
      ));
      await _swipeThroughIntro(tester);

      // did not change page:
      expect(find.widgetWithText(TextField, "Enter support code here"),
          findsOneWidget);

      await tester.enterText(
          find.widgetWithText(TextField, "Enter support code here"),
          supportCode);
      await tester.enterText(
          find.widgetWithText(TextField, "Enter postcode here"), postcode);

      await withClock(Clock.fixed(DateTime(2021)),
          () async => await tester.tap(find.text("Done")));

      verify(mockedUserWellbeingDB.insertWithData(
        date: "2021-01-01",
        postcode: postcode,
        numSteps: 0,
        wellbeingScore: 0.0,
        sputumColour: 0.0,
        mrcDyspnoeaScale: 0.0,
        speechRateTest: 0,
        testDuration: 30,
        speechRate: 0,
        audioURL: null,
        supportCode: supportCode,
      ));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      assert(prefs.getString('postcode') == postcode);
      assert(prefs.getString('support_code') == supportCode);
    });

    testWidgets('Sign up unsuccessful, no post code provided',
        (WidgetTester tester) async {
      final mockedUserWellbeingDB = MockedUserWellbeingDB();
      final supportCode = "GP";
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(wrapAppProvider(
        IntroScreen(),
        wbDB: mockedUserWellbeingDB,
      ));
      await _swipeThroughIntro(tester);

      await tester.enterText(
          find.widgetWithText(TextField, "Enter support code here"),
          supportCode);

      await withClock(Clock.fixed(DateTime(2021)),
          () async => await tester.tap(find.text("Done")));

      verifyNever(mockedUserWellbeingDB.insertWithData(
        date: anyNamed("date"),
        postcode: anyNamed("postcode"),
        wellbeingScore: anyNamed("wellbeingScore"),
        numSteps: anyNamed("numSteps"),
        supportCode: anyNamed("supportCode"),
      ));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      assert(prefs.getString('postcode') == null);
      assert(prefs.getString('support_code') == null);
    });
  });
}

void introPagesIntegrationTest() {
  main();
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
