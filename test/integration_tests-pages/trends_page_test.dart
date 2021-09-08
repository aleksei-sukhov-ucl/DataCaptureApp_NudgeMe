import 'package:charts_flutter/flutter.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/bar_graph.dart';
import 'package:nudge_me/pages/charts_page/graph_page.dart';
import 'package:nudge_me/pages/charts_page/line_graph.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import '../widget_test.dart';

void main() {
  final card = cards[4];
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

  List<WellbeingItem> wellbeingItemList = [];
  final nextDate =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  for (int i = 0; i < 35; i++) {
    if (i % 7 == 0) {
      wellbeingItemList.add(WellbeingItem(
          id: 1,
          date: nextDate
              .subtract(Duration(days: (28 - i)))
              .toIso8601String()
              .substring(0, 10),
          postcode: "E1",
          numSteps: 8888 - i,
          wellbeingScore: 10.0 - i / 100,
          sputumColour: 2.0 - i / 100,
          mrcDyspnoeaScale: 2.0 - i / 100,
          speechRate: 0,
          speechRateTest: 0,
          testDuration: 30,
          audioURL: "",
          supportCode: ""));
    }
  }

  wellbeingItemList.add(wellbeingItem);
  wellbeingItemList.removeAt(0);

  group("Correctly displays Trends Graph - not data available", () {
    testWidgets("Correctly displays Trends Graph - not data available",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      when(mockedUserWellbeingDB.getOverallTrendsForPastNWeeks(5))
          .thenAnswer((_) async => <WellbeingItem>[]);

      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      // Find no time frame toggle
      final toggle = find.byType(ToggleSwitch);
      expect(toggle, findsNothing);

      // Find Graph card
      final graphCard = find.byKey(Key("Graph Card"));
      expect(graphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: graphCard, matching: find.text(card.units));
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

      final lineChartWidget = find.byType(LineChart);
      expect(lineChartWidget, findsNothing);

      // final noDataText = find.ancestor(
      //     of: find.byType(LineChartTrends),
      //     matching: find.text("No data available"));
      //
      // expect(noDataText, findsOneWidget);

      expect(find.text("No data available"), findsOneWidget);

      //Make sure that the card displays correct description
      final findDescriptionCard = find.byKey(Key("Card Description"));

      final descriptionBody = find.descendant(
          of: findDescriptionCard,
          matching: find.byWidget(card.cardDescription));
      expect(descriptionBody, findsOneWidget);
    });
  });

  group("Correctly displays Trends Graph - Not Enough Data", () {
    testWidgets("Correctly displays Trends Graph - Not Enough Data",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      when(mockedUserWellbeingDB.getOverallTrendsForPastNWeeks(5))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      // Find no time frame toggle
      final toggle = find.byType(ToggleSwitch);
      expect(toggle, findsNothing);

      // Find Graph card
      final graphCard = find.byKey(Key("Graph Card"));
      expect(graphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: graphCard, matching: find.text(card.units));
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

      final lineChartWidget = find.byType(LineChart);
      expect(lineChartWidget, findsNothing);

      // final noDataText = find.ancestor(
      //     of: find.byType(LineChartTrends),
      //     matching: find.text("No data available"));
      //
      // expect(noDataText, findsOneWidget);

      expect(find.text("No data available"), findsNothing);

      expect(
          find.text(
              "Not Enough data yet, at least 3 weeks of data is required. \n\nPlease come back later!"),
          findsOneWidget);

      //Make sure that the card displays correct description
      final findDescriptionCard = find.byKey(Key("Card Description"));

      final descriptionBody = find.descendant(
          of: findDescriptionCard,
          matching: find.byWidget(card.cardDescription));
      expect(descriptionBody, findsOneWidget);
    });
  });

  group("Correctly displays Trends Graph - Shows the Graph", () {
    testWidgets("Correctly displays Trends Graph - Shows the Graph",
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      when(mockedUserWellbeingDB.getOverallTrendsForPastNWeeks(5))
          .thenAnswer((_) async => wellbeingItemList);
      print("wellbeingItemList: ${wellbeingItemList.length}");
      await tester.pumpWidget(
          wrapAppProvider(ChartPage(card: card), wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle();

      // Find no time frame toggle
      final toggle = find.byType(ToggleSwitch);
      expect(toggle, findsNothing);

      // Find Graph card
      final graphCard = find.byKey(Key("Graph Card"));
      expect(graphCard, findsOneWidget);

      //Make sure that the card displays correct units
      // fined Month Toggle
      final cardUnits =
          find.descendant(of: graphCard, matching: find.text(card.units));
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

      final lineChartWidget = find.byType(LineChart);
      expect(lineChartWidget, findsNothing);

      expect(find.text("No data available"), findsNothing);

      expect(
          find.text(
              "Not Enough data yet, at least 3 weeks of data is required. \n\nPlease come back later!"),
          findsNothing);

      expect(find.byType(LineChartTrends), findsOneWidget);

      //Make sure that the card displays correct description
      final findDescriptionCard = find.byKey(Key("Card Description"));

      final descriptionBody = find.descendant(
          of: findDescriptionCard,
          matching: find.byWidget(card.cardDescription));
      expect(descriptionBody, findsOneWidget);
    });
  });
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
