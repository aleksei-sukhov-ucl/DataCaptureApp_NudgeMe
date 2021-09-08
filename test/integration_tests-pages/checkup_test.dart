import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/checkup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock/clock.dart';

import '../widget_test.dart';

final numberOfSliders = 3;
void main() {
  testWidgets('Find all the key parts of the weekly checkup',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'postcode': 'N6', 'support_code': '12345', PREV_STEP_COUNT_KEY: 0});
    final fakeStepStream = Stream.fromIterable([7777]);

    await tester.pumpWidget(wrapAppProvider(
      WellbeingCheck(fakeStepStream),
    ));
    await tester.pumpAndSettle();

    // Find how many sliders present
    final sliderFind = find.byType(Slider);
    expect(sliderFind, findsNWidgets(numberOfSliders));

    //Find Step Count
    final stepCount = find.text("7777");
    expect(stepCount, findsOneWidget);

    //Find Wellbeing Check
    final wellbeingCheck = find.text("How did you feel this week?");
    expect(wellbeingCheck, findsOneWidget);

    //Find Sputum Color Check
    final sputumColorCheck =
        find.text("Over the past 7 days, rate what color your sputum was.");
    expect(sputumColorCheck, findsOneWidget);

    //Find MRC Dysonea Scale Check
    final mrcDysoneaScaleCheck =
        find.text("Over the past 7 days, rate your level of breathlessness.");
    expect(mrcDysoneaScaleCheck, findsOneWidget);

    //Find Speech Rate Check
    final speechRateCheck = find.text("Please select the type of test:");
    expect(speechRateCheck, findsOneWidget);

    //Find Speech Rate Check
    final speechTestCheck = find.text(
        "In this test, you will be asked to say \"Hippopotamus\" as many times as possible in a selected time");
    expect(speechTestCheck, findsOneWidget);

    //Find audio recording button
    final findRecordingButton = find.byType(RawMaterialButton);
    expect(findRecordingButton, findsOneWidget);
  });

  testWidgets('Correctly adds to DB', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'postcode': 'N6', 'support_code': '12345', PREV_STEP_COUNT_KEY: 0});
    final mockedDB = _MockedDB();
    when(mockedDB.getLastNDaysAvailable(3))
        .thenAnswer((_) async => <WellbeingItem>[]);
    final fakeStepStream = Stream.fromIterable([7777]);

    await tester.pumpWidget(wrapAppProvider(
      WellbeingCheck(fakeStepStream),
      wbDB: mockedDB,
    ));
    await tester.pumpAndSettle();

    // should be 5 for MRC Dysponea Scale
    //First find container of the slider
    final parentFinder = find.byKey(Key('MRCDysoneaScale'));
    expect(parentFinder, findsOneWidget);
    //Now fined the slider
    final sliderFinder =
        find.descendant(of: parentFinder, matching: find.byType(Slider));

    await tester.drag(sliderFinder, Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    //Scroll down to view audio recording
    await tester.dragUntilVisible(
      find.text('Waiting to record'), // what you want to find
      find.byKey(Key('MRCDysoneaScale')), // widget you want to scroll
      const Offset(0, -500), // delta to move
    );

    ///Todo:ref https://stackoverflow.com/questions/56291806/flutter-how-to-test-the-scroll

    await withClock(
        // this should use the fake clock when requesting date
        Clock.fixed(DateTime(2021)),
        () async => await tester.tap(find.byType(ElevatedButton)));
    await tester.pump();

    verify(mockedDB.getLastNDaysAvailable(3));
    verify(mockedDB.insertWithData(
        date: "2021-01-01",
        postcode: 'N6',
        wellbeingScore: 0,
        sputumColour: 0,
        mrcDyspnoeaScale: 4,
        speechRate: 0,
        speechRateTest: 0,
        testDuration: 30,
        audioURL: null,
        numSteps: 7777,
        supportCode: '12345'));
  });

  testWidgets('Works when steps reset', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(
        {'postcode': 'N6', 'support_code': '12345', PREV_STEP_COUNT_KEY: 8888});
    final mockedDB = _MockedDB();
    when(mockedDB.getLastNDaysAvailable(3))
        .thenAnswer((_) async => <WellbeingItem>[]);
    final fakeStepStream = Stream.fromIterable([7777]);

    await tester.pumpWidget(
        wrapAppProvider(WellbeingCheck(fakeStepStream), wbDB: mockedDB));
    await tester.pumpAndSettle();

    // should be at score of 10 after dragging
    final parentFinder = find.byKey(Key('Welleing Slider'));
    expect(parentFinder, findsOneWidget);
    //Now fined the slider
    final sliderFinder =
        find.descendant(of: parentFinder, matching: find.byType(Slider));

    await tester.drag(sliderFinder, Offset(500.0, 0.0));
    await tester.pumpAndSettle();

    //Scroll down to view audio recording
    await tester.dragUntilVisible(
      find.text('Waiting to record'), // what you want to find
      find.byKey(Key('MRCDysoneaScale')), // widget you want to scroll
      const Offset(0, -500), // delta to move
    );

    await withClock(
        // this should use the fake clock when requesting date
        Clock.fixed(DateTime(2021)),
        () async => await tester.tap(find.byType(ElevatedButton)));

    verify(mockedDB.getLastNDaysAvailable(3));
    verify(mockedDB.insertWithData(
        date: "2021-01-01",
        postcode: 'N6',
        numSteps: 7777,
        wellbeingScore: 10,
        sputumColour: 0,
        mrcDyspnoeaScale: 0,
        speechRate: 0,
        speechRateTest: 0,
        testDuration: 30,
        audioURL: null,
        supportCode: '12345'));
    final newPrev = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt(PREV_STEP_COUNT_KEY));
    assert(newPrev == 7777);
  });
}

class _MockedDB extends Mock implements UserWellbeingDB {}
