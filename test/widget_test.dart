// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// wraps a [Widget] with [MaterialApp] and also provides databases
Widget wrapAppProvider(Widget w, {UserWellbeingDB wbDB, FriendDB friendDB}) {
  if (wbDB == null) {
    wbDB = MockedWBDB();
  }
  if (friendDB == null) {
    friendDB = MockedFriendDB();
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: wbDB,
      ),
      ChangeNotifierProvider.value(
        value: friendDB,
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 251, 249, 255),
        // primaryColor: Color.fromARGB(255, 0, 74, 173),
        primaryColor: Color.fromRGBO(113, 101, 226, 1),
        // accentColor: Color.fromARGB(255, 182, 125, 226),
        fontFamily: 'Lato-Regular',
        textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 38.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nato-Sans'),
            headline2: TextStyle(
              fontFamily: 'KiteOne-Regular',
              fontSize: 25,
            ),
            headline3: TextStyle(fontFamily: 'KiteOne-Regular', fontSize: 25),
            subtitle1: TextStyle(
                fontFamily: 'KiteOne-Regular',
                fontWeight: FontWeight.w500,
                fontSize: 20),
            subtitle2: TextStyle(
                fontFamily: 'KiteOne-Regular',
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 20), //for tutorial
            bodyText1: TextStyle(fontFamily: 'KiteOne-Regular', fontSize: 20),
            bodyText2: TextStyle(fontFamily: 'KiteOne-Regular', fontSize: 15),
            caption: TextStyle(fontFamily: 'KiteOne-Regular', fontSize: 12)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'KiteOne-Regular',
              fontSize: 14.0),
          unselectedLabelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'KiteOne-Regular',
              fontSize: 14.0),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          showUnselectedLabels: true,
        ),
        colorScheme: ColorScheme(
          primary: Color.fromRGBO(113, 101, 226, 1),
          secondary: Color.fromRGBO(63, 135, 253, 1),

          /// Steps Color
          primaryVariant: Color.fromRGBO(123, 230, 236, 1),

          ///Wellbeing color
          secondaryVariant: Colors.deepPurple,

          /// Sputum colour
          surface: Color.fromRGBO(113, 101, 226, 1),

          ///MRC Dyspnoea Scale
          background: Color.fromRGBO(138, 127, 245, 1),
          error: Colors.white,

          onPrimary: Colors.white,

          ///Speech Rate
          onSecondary: Color.fromRGBO(241, 139, 128, 1.0),
          onSurface: Colors.white,
          onBackground: Color.fromRGBO(251, 222, 147, 1),
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),
      home: w,
    ),
  );
}

void main() {
  testWidgets('Intro screen displayed smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text("Welcome"), findsOneWidget);
  });
}

class MockedFriendDB extends Mock implements FriendDB {}

class MockedWBDB extends Mock implements UserWellbeingDB {}
