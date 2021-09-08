import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/bar_graph.dart';
import 'package:nudge_me/pages/charts_page/line_graph.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/shared/share_export_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import '../widget_test.dart';

void main() {
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

  group("Correctly displays Export Page - export steps", () {
    testWidgets("Correctly displays Export Page - export steps",
        (WidgetTester tester) async {
      final card = cards[0];
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(wrapAppProvider(
          PDFExportPage(
              timeFrame: 0,
              exportSteps: true,
              exportWellbeing: false,
              exportBreathlessness: false,
              exportSputumColor: false,
              exportOverallTrends: false),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find how many bar charts in total
      final exportStepsCard = find.byType(BarChartWidget);
      expect(exportStepsCard, findsOneWidget);
      // Find Steps Card
      expect(find.text(cards[0].titleOfCard), findsOneWidget);

      // Find Wellbeing Card
      expect(find.text(cards[1].titleOfCard), findsNothing);
      //
      // Find Sputum Color Card
      expect(find.text(cards[2].titleOfCard), findsNothing);
      //
      // Find Breathlessness Card
      expect(find.text(cards[3].titleOfCard), findsNothing);
      //
      // Find Trends Card
      expect(find.text(cards[4].titleOfCard), findsNothing);
    });
  });

  group("Correctly displays Export Page - export Wellbeing", () {
    testWidgets("Correctly displays Export Page - export Wellbeing",
        (WidgetTester tester) async {
      final card = cards[1];
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(wrapAppProvider(
          PDFExportPage(
              timeFrame: 0,
              exportSteps: false,
              exportWellbeing: true,
              exportBreathlessness: false,
              exportSputumColor: false,
              exportOverallTrends: false),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find how many bar charts in total
      final exportStepsCard = find.byType(BarChartWidget);
      expect(exportStepsCard, findsOneWidget);
      // Find Steps Card
      expect(find.text(cards[0].units), findsNothing);

      // Find Wellbeing Card
      expect(find.text(cards[1].titleOfCard), findsOneWidget);
      //
      // Find Sputum Color Card
      expect(find.text(cards[2].titleOfCard), findsNothing);
      //
      // Find Breathlessness Card
      expect(find.text(cards[3].titleOfCard), findsNothing);
      //
      // Find Trends Card
      expect(find.text(cards[4].titleOfCard), findsNothing);
    });
  });

  group("Correctly displays Export Page - export Sputum Color", () {
    testWidgets("Correctly displays Export Page - export Sputum Color",
        (WidgetTester tester) async {
      final card = cards[2];
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(wrapAppProvider(
          PDFExportPage(
              timeFrame: 0,
              exportSteps: false,
              exportWellbeing: false,
              exportSputumColor: true,
              exportBreathlessness: false,
              exportOverallTrends: false),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle(const Duration(seconds: 7));

      // Find how many bar charts in total
      final exportStepsCard = find.byType(BarChartWidget);
      expect(exportStepsCard, findsOneWidget);
      // Find Steps Card
      expect(find.text(cards[0].titleOfCard), findsNothing);

      // Find Wellbeing Card
      expect(find.text(cards[1].titleOfCard), findsNothing);
      //
      // Find Sputum Color Card
      expect(find.text(cards[2].titleOfCard), findsOneWidget);
      //
      // Find Breathlessness Card
      expect(find.text(cards[3].titleOfCard), findsNothing);
      //
      // Find Trends Card
      expect(find.text(cards[4].units), findsNothing);
    });
  });

  group("Correctly displays Export Page - export Breathlessness", () {
    testWidgets("Correctly displays Export Page - export Breathlessness",
        (WidgetTester tester) async {
      final card = cards[3];
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(wrapAppProvider(
          PDFExportPage(
              timeFrame: 0,
              exportSteps: false,
              exportWellbeing: false,
              exportSputumColor: false,
              exportBreathlessness: true,
              exportOverallTrends: false),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find how many bar charts in total
      final exportStepsCard = find.byType(BarChartWidget);
      expect(exportStepsCard, findsOneWidget);
      // Find Steps Card
      expect(find.text(cards[0].titleOfCard), findsNothing);

      // Find Wellbeing Card
      expect(find.text(cards[1].titleOfCard), findsNothing);
      //
      // Find Sputum Color Card
      expect(find.text(cards[2].titleOfCard), findsNothing);
      //
      // Find Breathlessness Card
      expect(find.text(cards[3].titleOfCard), findsOneWidget);
      //
      // Find Trends Card
      expect(find.text(cards[4].units), findsNothing);
    });
  });

  group("Correctly displays Export Page - export Trends", () {
    testWidgets("Correctly displays Export Page - export Trends",
        (WidgetTester tester) async {
      final card = cards[4];
      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "W"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      when(mockedUserWellbeingDB.getLastMonthYearSpecificColumns(
              ids: [card.cardId + 3], timeframe: "m"))
          .thenAnswer((_) async => <WellbeingItem>[wellbeingItem]);

      SharedPreferences.setMockInitialValues({
        'postcode': 'N6',
        'support_code': '12345',
        PREV_PEDOMETER_PAIR_KEY: ["0", DateTime.now().toIso8601String()]
      });

      await tester.pumpWidget(wrapAppProvider(
          PDFExportPage(
              timeFrame: 0,
              exportSteps: false,
              exportWellbeing: false,
              exportSputumColor: false,
              exportBreathlessness: false,
              exportOverallTrends: true),
          wbDB: mockedUserWellbeingDB));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find how many bar charts in total
      final findBarChart = find.byType(BarChartWidget);
      expect(findBarChart, findsNothing);

      expect(find.byType(LineChartTrends), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);

      // Find Trends Card
      expect(find.text(cards[4].units), findsOneWidget);
    });
  });
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
