import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_test.dart';

// NOTE: update this if the number of pages in intro screen changes
const numberOfPages = 9;

Future<Null> _swipeThroughIntro(WidgetTester tester) async {
  //First Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Second Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Third Page
  await tester.drag(find.byType(Icon), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Fourth Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Fifth Page
  await tester.drag(find.byType(Icon), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Sixth Page
  await tester.drag(find.byType(Icon), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Seventh Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  // //Eighth Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
  //Ninth Page
  await tester.drag(find.byType(Image), Offset(-400.0, 0.0));
  await tester.pumpAndSettle(Duration(seconds: 1));
}

void main() {
  testWidgets('Swiping switches page', (WidgetTester tester) async {
    await tester.pumpWidget(wrapAppProvider(IntroScreen()));

    expect(find.text("Welcome"), findsOneWidget);
    await tester.drag(find.byType(Image), Offset(-500.0, 0.0));
    await tester.pumpAndSettle(new Duration(seconds: 2));
    expect(find.text("Welcome"), findsNothing);
    expect(find.text("How?"), findsOneWidget);
  });

  // this test probably seems trivial, but I actually found a bug with it.
  testWidgets('Swipes through without exception', (WidgetTester tester) async {
    await tester.pumpWidget(
        wrapAppProvider(IntroScreen()), Duration(seconds: 2));

    await _swipeThroughIntro(tester);
  });

  // testWidgets('Adds first checkup to DB and updates prefs',
  //     (WidgetTester tester) async {
  //   final mockedDB = _MockedDB();
  //   final supportCode = "GP";
  //   final postcode = "M11";
  //   SharedPreferences.setMockInitialValues({});
  //
  //   await tester.pumpWidget(wrapAppProvider(
  //     IntroScreen(),
  //     wbDB: mockedDB,
  //   ));
  //   await _swipeThroughIntro(tester);
  //
  //   // did not change page:
  //   // expect(find.widgetWithText(TextField, "Enter support code here"),
  //   //     findsOneWidget);
  //
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Enter support code here"), supportCode);
  //   await tester.enterText(
  //       find.widgetWithText(TextField, "Enter postcode here"), postcode);
  //
  //   await withClock(Clock.fixed(DateTime(2021)),
  //       () async => await tester.tap(find.text("Done")));
  //
  //   verify(mockedDB.insertWithData(
  //     date: "2021-01-01",
  //     postcode: postcode,
  //     wellbeingScore: 0.0,
  //     numSteps: 0,
  //     sputumColour: 0.0,
  //     mrcDyspnoeaScale: 0.0,
  //     supportCode: supportCode,
  //   ));
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   assert(prefs.getString('postcode') == postcode);
  //   assert(prefs.getString('support_code') == supportCode);
  // });

  testWidgets('Does not add to DB or prefs if postcode missing',
      (WidgetTester tester) async {
    final mockedDB = _MockedDB();
    final supportCode = "GP";
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(wrapAppProvider(
      IntroScreen(),
      wbDB: mockedDB,
    ));
    await _swipeThroughIntro(tester);

    await tester.enterText(
        find.widgetWithText(TextField, "Enter support code here"), supportCode);

    await withClock(Clock.fixed(DateTime(2021)),
        () async => await tester.tap(find.text("Done")));

    verifyNever(mockedDB.insertWithData(
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
}

class _MockedDB extends Mock implements UserWellbeingDB {}
