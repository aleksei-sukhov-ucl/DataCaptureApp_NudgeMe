import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/bar_graph.dart';
import 'package:nudge_me/pages/charts_page/graph_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import '../widget_test.dart';

void main() {
  final card = cards[2];
  final mockedUserWellbeingDB = MockedUserWellbeingDB();
  final wellbeingItem = WellbeingItem(
      id: 1,
      date: DateTime.now().toIso8601String().substring(0, 10),
      postcode: "E1",
      numSteps: 8888,
      wellbeingScore: 10.0,
      sputumColour: 2.0,
      mrcDyspnoeaScale: 2.0,
      speechRate: 0,
      speechRateTest: 0,
      testDuration: 30,
      audioURL: "",
      supportCode: "");

  group("Correctly displays Sputum Bar Graph", () {
    testWidgets("Correctly displays Sputum Bar Graph",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      // Find time frame toggle
      final toggle = find.byType(ToggleSwitch);
      // fined Week Toggle
      final findWeekToggle =
          find.descendant(of: toggle, matching: find.text('Week'));
      expect(findWeekToggle, findsNothing);

      // fined Month Toggle
      final findMonthToggle =
          find.descendant(of: toggle, matching: find.text('Month'));
      expect(findMonthToggle, findsOneWidget);

      // fined Year Toggle
      final findYearToggle =
          find.descendant(of: toggle, matching: find.text('Year'));
      expect(findYearToggle, findsOneWidget);

      // Find Graph card
      final barGraphCard = find.byKey(Key("Graph Card"));
      expect(barGraphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: barGraphCard, matching: find.text(card.units));
      expect(cardUnits, findsOneWidget);

      //End date should be today's date
      final endDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
      final findEndDateAnnotation = find.text(endDate);
      expect(findEndDateAnnotation, findsOneWidget);

      //Start date should be (27 + week day )before today's date
      final startDate = DateFormat.yMMMMd('en_US').format(
          DateTime.now().subtract(Duration(days: 27 + DateTime.now().weekday)));
      final findStartDateAnnotation = find.text(startDate);
      expect(findStartDateAnnotation, findsOneWidget);

      final barChartWidget = find.byType(BarChartWidget);
      expect(barChartWidget, findsOneWidget);

      //Make sure that the card displays correct description
      final findDescriptionCard = find.byKey(Key("Card Description"));
      expect(findDescriptionCard, findsOneWidget);

      final descriptionBody = find.descendant(
          of: findDescriptionCard,
          matching: find.byWidget(card.cardDescription));
      expect(descriptionBody, findsOneWidget);
    });
  });

  group("Falls back to default bar graph", () {
    testWidgets("Falls back to default bar graph", (WidgetTester tester) async {
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      // Find time frame toggle
      final toggle = find.byType(ToggleSwitch);
      // fined Week Toggle
      final findWeekToggle =
          find.descendant(of: toggle, matching: find.text('Week'));
      expect(findWeekToggle, findsNothing);

      // fined Month Toggle
      final findMonthToggle =
          find.descendant(of: toggle, matching: find.text('Month'));
      expect(findMonthToggle, findsOneWidget);

      // fined Year Toggle
      final findYearToggle =
          find.descendant(of: toggle, matching: find.text('Year'));
      expect(findYearToggle, findsOneWidget);

      // Find Graph card
      final barGraphCard = find.byKey(Key("Graph Card"));
      expect(barGraphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: barGraphCard, matching: find.text(card.units));
      expect(cardUnits, findsOneWidget);

      //End date should be today's date
      final endDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
      final findEndDateAnnotation = find.text(endDate);
      expect(findEndDateAnnotation, findsOneWidget);

      //Start date should be (27 + week day )before today's date
      final startDate = DateFormat.yMMMMd('en_US').format(
          DateTime.now().subtract(Duration(days: 27 + DateTime.now().weekday)));
      final findStartDateAnnotation = find.text(startDate);
      expect(findStartDateAnnotation, findsOneWidget);

      final barChartWidget = find.byType(BarChartWidget);
      expect(barChartWidget, findsOneWidget);
    });
  });

  group("Switching to Year View", () {
    testWidgets("Switching to Year View", (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      final toggle = find.byKey(Key("Toggle"));

      // fined Month Toggle
      final findYearToggle =
          find.descendant(of: toggle, matching: find.text('Year'));
      expect(findYearToggle, findsOneWidget);

      await withClock(
          // this should use the fake clock when requesting date
          Clock.fixed(DateTime(2021)),
          () async => await tester.tap(findYearToggle));
      await tester.pump();

      // Find Graph card
      final barGraphCard = find.byKey(Key("Graph Card"));
      expect(barGraphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: barGraphCard, matching: find.text(card.units));
      expect(cardUnits, findsOneWidget);

      //End date should be today's date
      final endDate = DateFormat.yMMMMd('en_US').format(DateTime.now());
      final findEndDateAnnotation = find.text(endDate);
      expect(findEndDateAnnotation, findsOneWidget);

      //Start date should be (27 + week day )before today's date
      final startDate = DateFormat.yMMMMd('en_US').format(DateTime.utc(
          DateTime.now().year, DateTime.now().month - 11, DateTime.now().day));
      final findStartDateAnnotation = find.text(startDate);
      expect(findStartDateAnnotation, findsOneWidget);

      final barChartWidget = find.byType(BarChartWidget);
      expect(barChartWidget, findsOneWidget);

      // Search for the share button
      expect(find.text("Share "), findsOneWidget);

      //Make sure that the card displays correct description
      final findDescriptionCard = find.byKey(Key("Card Description"));
      expect(findDescriptionCard, findsOneWidget);

      final descriptionBody = find.descendant(
          of: findDescriptionCard,
          matching: find.byWidget(card.cardDescription));
      expect(descriptionBody, findsOneWidget);
    });
  });
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
