import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/graph_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  group("PDF Modal Loads Correctly", () {
    testWidgets("PDF Modal Loads Correctly", (WidgetTester tester) async {
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

      // Search for the share button
      final shareButton = find.text("Share ");
      expect(shareButton, findsOneWidget);

      await withClock(
          // this should use the fake clock when requesting date
          Clock.fixed(DateTime(2021)),
          () async => await tester.tap(shareButton));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Search for the PDF Sharing Modal
      final pdfSharingModal = find.byType(AlertDialog);
      expect(pdfSharingModal, findsOneWidget);

      //Find modal title
      expect(find.text("Share Preferences"), findsOneWidget);

      //Find time frame preferences
      expect(find.text("Select Time Frame"), findsOneWidget);
      expect(find.byKey(Key("Select Month")), findsOneWidget);
      expect(find.byKey(Key("Select Year")), findsOneWidget);

      //Find selection of what data to export
      expect(find.text("Select Data to Export"), findsOneWidget);
      expect(find.text("Steps"), findsOneWidget);
      expect(find.text('Wellbeing Score'), findsOneWidget);
      expect(find.byKey(Key("Select Sputum Color")), findsOneWidget);
      expect(find.text('MRC Dyspnoea Scale Score'), findsOneWidget);
      expect(find.text('Overall Trends (Past 5 weeks)'), findsOneWidget);

      final exportButton = find.text('Export');
      await withClock(
          // this should use the fake clock when requesting date
          Clock.fixed(DateTime(2021)),
          () async => await tester.tap(exportButton));
      await tester.pumpAndSettle(Duration(seconds: 2));

      //Find modal title
      expect(find.text("Share Preferences"), findsOneWidget);
    });
  });
}

class MockedUserWellbeingDB extends Mock implements UserWellbeingDB {}
//Android -> IOS
// Add me on NudgeMe by clicking this:
// https://health.nudgemehealth.co.uk/add-friend?identifier=a8e1f0acea8aba35a3c4e2e779c3cc8618b75bb&pubKey=-----BEGIN%20RSA%20PUBLIC%20KEY-----%0AMIIBCgKCAQEAsKfpRZBBX0defF5Cvkv9wMc92LgJ4zV%2BaUhKCkpa45X20QWC%2B%2Fr6wcswt60s20S94LxLComf1pBaa4sjS3M8PIuOpOd5IzcMW0vV4hZP76bYckfMuIp77j6MTxryln0V9hDu%2Fspdojq13TAiIEYUOPquddsd93dwMXxpPWcUhP%2F5mBIvK5Y5edwycVx%2FrNFBl5CvCU4DitBmWfJ%2B1pR60kDT95FWccDYOTu7d%2BeMqn76V0v1sVxe9%2By7UdvOb3SdCOHcWR5itz6XO1MKSKR1xyVJbz35WTGWasgtMScunJrNBwCcuzBd1cZQPWYMcdgquJ%2FiNh%2BilVVnifF4XsXQbwIDAQAB%0A-----END%20RSA%20PUBLIC%20KEY-----

//IOS -> Android
//Add me on NudgeMe by clicking this:
//https://health.nudgemehealth.co.uk/add-friend?identifier=2e11b636d9482459399c54a72bb7dd9fdf1fa2c5&pubKey=-----BEGIN%20RSA%20PUBLIC%20KEY-----%0AMIIBCgKCAQEAuee%2F8PhP%2F7zHQ28n46%2F09Ar9J8ldWxrdDkV%2BAbaRvzqG5kOV76CjjMZH%2FsE8opZw6jpSjHWID7SaMqfB9KH8AMd3ml%2BrfbqakhLF5Uc84dpor8xbijJWc8RydaQrXhal7qtehbcaHB%2Bzpsa%2FY7ww877NFon7%2FYytPKg8aWtdm1R65Y%2BdOc6f7GNQUybJ9Jb3jEA9w46qXBs23y0f18xbbIgHALAKtRKQzCaZolZ6e7sgS1N3z6Tjel0ASlkRXGMpzKZmz7M5hhGe0%2Bnx22%2Bb9JGHySdPrugI28anhY4L9oKBERe%2FllRrltxL6qS6aFT7aUqgIQvepjTV6rpHrxpuPQIDAQAB%0A-----END%20RSA%20PUBLIC%20KEY-----
