import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/notification.dart';
import 'package:nudge_me/pages/checkup.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class TestingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text("Debug Page (NOT IN FINAL APP)"),
          ElevatedButton(
            onPressed: () {
              final datetime =
                  tz.TZDateTime.now(tz.local).add(Duration(seconds: 1));
              scheduleCheckupOnce(datetime);
            },
            child: Text("Wellbeing Check Notification"),
          ),
          ElevatedButton(
            onPressed: () => scheduleNudge(),
            child: Text("Example Nudge"),
          ),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WellbeingCheck(
                          Pedometer.stepCountStream.map((sc) => sc.steps)))),
              child: Text("Wellbeing Check Screen")),

          /// Generating a single Wellbeing item
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final dateStr = DateTime.now().toIso8601String().substring(0, 10);
              UserWellbeingDB().insert(WellbeingItem(
                date: dateStr,
                postcode: prefs.getString('postcode'),
                numSteps: Random().nextInt(10001),
                wellbeingScore: Random().nextDouble() * 10.0,
                sputumColour: Random().nextInt(5).toDouble(),
                mrcDyspnoeaScale: Random().nextDouble() * 6.0,
                speechRate: Random().nextDouble() * 100.0,
                audioURL: "helloworld",
                supportCode: prefs.getString('support_code'),
              ));
            },
            child: Text("Generate WellbeingItem"),
          ),

          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final dateStr = DateTime.now()
                  .subtract(Duration(days: 1))
                  .toIso8601String()
                  .substring(0, 10);
              UserWellbeingDB().insert(WellbeingItem(
                date: dateStr,
                postcode: prefs.getString('postcode'),
                numSteps: Random().nextInt(10001),
                wellbeingScore: Random().nextDouble() * 10.0,
                sputumColour: Random().nextInt(5).toDouble(),
                mrcDyspnoeaScale: Random().nextDouble() * 5.0,
                speechRate: Random().nextDouble() * 100.0,
                audioURL: "helloworld",
                supportCode: prefs.getString('support_code'),
              ));
            },
            child: Text("Generate WellbeingItem for yesterday"),
          ),

          /// Generating a week much wellbeing item
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final List<DateTime> dateStrs = List<DateTime>.generate(
                  7,
                  (subtractingDay) =>
                      DateTime.now().subtract(Duration(days: subtractingDay)));
              DateTime.now().toIso8601String().substring(0, 10);
              dateStrs.forEach((dateStr) {
                UserWellbeingDB().insert(WellbeingItem(
                  postcode: prefs.getString('postcode'),
                  numSteps: Random().nextInt(10001),
                  wellbeingScore: Random().nextInt(10).toDouble(),
                  sputumColour: Random().nextInt(5).toDouble(),
                  mrcDyspnoeaScale: Random().nextInt(5).toDouble(),
                  speechRate: Random().nextInt(200).toDouble(),
                  audioURL: "helloworld",
                  supportCode: prefs.getString('support_code'),
                  date: dateStr.toIso8601String().substring(0, 10),
                ));
              });
            },
            child: Text("Generate WellbeingItem for a week"),
          ),

          /// Generate a month long amount of data for DB
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final List<DateTime> dateStrs = List<DateTime>.generate(
                  30,
                  (subtractingDay) =>
                      DateTime.now().subtract(Duration(days: subtractingDay)));
              DateTime.now().toIso8601String().substring(0, 10);
              dateStrs.forEach((dateStr) {
                UserWellbeingDB().insert(WellbeingItem(
                  postcode: prefs.getString('postcode'),
                  numSteps: Random().nextInt(10001),
                  wellbeingScore: Random().nextInt(10).toDouble(),
                  sputumColour: Random().nextInt(5).toDouble(),
                  mrcDyspnoeaScale: Random().nextInt(5).toDouble(),
                  speechRate: Random().nextInt(200).toDouble(),
                  audioURL: "helloworld",
                  supportCode: prefs.getString('support_code'),
                  date: dateStr.toIso8601String().substring(0, 10),
                ));
              });
            },
            child: Text("Generate WellbeingItem for a month"),
          ),

          /// Generate a month long amount of data for DB
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final List<DateTime> dateStrs = List<DateTime>.generate(
                  365,
                  (subtractingDay) =>
                      DateTime.now().subtract(Duration(days: subtractingDay)));
              DateTime.now().toIso8601String().substring(0, 10);
              dateStrs.forEach((dateStr) {
                UserWellbeingDB().insert(WellbeingItem(
                  postcode: prefs.getString('postcode'),
                  numSteps: Random().nextInt(15001),
                  wellbeingScore: Random().nextInt(10).toDouble(),
                  sputumColour: Random().nextInt(5).toDouble(),
                  mrcDyspnoeaScale: Random().nextInt(5).toDouble(),
                  speechRate: Random().nextInt(200).toDouble(),
                  audioURL: "helloworld",
                  supportCode: prefs.getString('support_code'),
                  date: dateStr.toIso8601String().substring(0, 10),
                ));
              });
            },
            child: Text("Generate WellbeingItem for a year"),
          ),
          ElevatedButton(
            onPressed: () => UserWellbeingDB().delete(),
            child: Text("Reset Wellbeing Data"),
          ),
          ElevatedButton(
            onPressed: () {
              final num = Random().nextInt(999);
              return FriendDB().insertWithData(
                name: "Friend $num",
                identifier: "id $num",
                publicKey: "key $num",
                latestData: null,
                sentActiveGoal: 0,
                read: null,
                currentStepsGoal: null,
              );
            },
            child: Text("Generate Random Friend"),
          )
        ]),
      ),
    );
  }
}
