import 'dart:convert';
import 'dart:math';

import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:nudge_me/crypto.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/main_pages.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/notification.dart';
import 'package:nudge_me/shared/wellbeing_graph.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:nudge_me/pages/support_page.dart';
import 'package:http/http.dart' as http;

// names of the background tasks handled by [Workmanager]:

/// refers to the task that checks if the pedometer has changed in the last
/// 48 hours
const PEDOMETER_CHECK_KEY = "pedometer_check";

/// refers to the task that checks if there is any new wellbeing data sent from
/// friends
const REFRESH_FRIEND_KEY = "refresh_friend_data";

/// refers to the task that checks if there are any nudges sent from friends
const NUDGE_CHECK_KEY = "nudge_check";

/// scheduled cron job for publishing data to the server
ScheduledTask publishTask;
ScheduledTask addDataToDB;

/// inits the [Workmanager] and registers a background task to track steps
/// and refresh friend data
void initBackground() {
  Workmanager.initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  Workmanager.registerPeriodicTask("pedometer_check_task", PEDOMETER_CHECK_KEY,
      frequency: Duration(minutes: 15));
  Workmanager.registerPeriodicTask("refresh_friend_task", REFRESH_FRIEND_KEY,
      frequency: Duration(minutes: 15), initialDelay: Duration(seconds: 10));
  Workmanager.registerPeriodicTask("nudge_check_task", NUDGE_CHECK_KEY,
      frequency: Duration(minutes: 15), initialDelay: Duration(minutes: 1));
}

/// sets up the callback handler for background tasks
void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) async {
    switch (taskName) {
      case PEDOMETER_CHECK_KEY:
        final prefs = await SharedPreferences.getInstance();
        final pedometerPair = prefs.getStringList(PREV_PEDOMETER_PAIR_KEY);
        assert(pedometerPair.length == 2);
        final prevTotal = int.parse(pedometerPair.first);
        final prevDateTime = DateTime.parse(pedometerPair.last);
        final int currTotal = await Pedometer.stepCountStream.first
            .then((value) => value.steps)
            .catchError((_) => 0);
        if (currTotal > prevTotal || currTotal < prevTotal) {
          // if steps have increased or the device has been rebooted
          prefs.setStringList(PREV_PEDOMETER_PAIR_KEY,
              [currTotal.toString(), DateTime.now().toIso8601String()]);
        } else if (currTotal == prevTotal &&
            DateTime.now().difference(prevDateTime) >= Duration(days: 2)) {
          // if step count hasn't changed in 2 days
          await initNotification(); // needs to be done since outside app
          await scheduleNudge();
          prefs.setStringList(PREV_PEDOMETER_PAIR_KEY,
              [currTotal.toString(), DateTime.now().toIso8601String()]);
        }
        break;
      case REFRESH_FRIEND_KEY:
        final bool newData = await getLatest();

        if (newData) {
          await initNotification();
          await scheduleNewFriendData();
        }
        break;
      case NUDGE_CHECK_KEY:
        await refreshNudge(true);
        await checkIfGoalsCompleted();
        break;
    }
    return Future.value(true); // task handled successfully
  });
}

/// POSTs to the back-end and updates the local DB if needed
Future<Null> refreshNudge(bool shouldInitNotifications) async {
  final prefs = await SharedPreferences.getInstance();
  final body = jsonEncode({
    'identifier': prefs.getString(USER_IDENTIFIER_KEY),
    'password': prefs.getString(USER_PASSWORD_KEY),
  });

  await http
      .post(Uri.parse(BASE_URL + "/user/nudge"),
          headers: {'Content-Type': 'application/json'}, body: body)
      .then((response) async {
    final List<dynamic> messages = jsonDecode(response.body);
    print("User Nudges received: $messages");

    if (messages.length > 0) {
      if (shouldInitNotifications) {
        await initNotification();
      }
      for (dynamic message in messages) {
        await _handleNudge(message);
      }
    }
  });
}

/// checks if message is from a known friend, and updates DB, depending on type of
/// nudge, if so
Future<Null> _handleNudge(dynamic message) async {
  final identifierFrom = message['identifier_from'];

  if (await FriendDB().isIdentifierPresent(identifierFrom)) {
    final data = json.decode(message['data']);
    if (data['type'] == null && data['goal'] == null) {
      return;
    }

    final name = await FriendDB().getName(identifierFrom);

    switch (data['type']) {
      case 'nudge-new': // friend sets you a goal
        final int currStepTotal = await Pedometer.stepCountStream.first
            .then((stepCount) => stepCount.steps)
            .catchError((_) => 0);
        await FriendDB()
            .updateGoalFromFriend(identifierFrom, data['goal'], currStepTotal);
        await scheduleNudgeNewGoal(name, data['goal']);
        break;
      case 'nudge-completed': // friend has completed your goal
        await FriendDB().updateActiveNudge(identifierFrom, false);
        await scheduleNudgeFriendCompletedGoal(name, data['goal']);
        break;
      default:
        print("Unknown nudge type.");
        break;
    }
  }
}

Future<Null> checkIfGoalsCompleted() async {
  final int currStepTotal = await Pedometer.stepCountStream.first
      .then((value) => value.steps)
      .catchError((_) => 0);
  final List<Friend> friends = await FriendDB().getFriends();

  // checking steps goal for every friend who has set us a goal
  for (Friend friend
      in friends.where((element) => element.currentStepsGoal != null)) {
    int actualSteps;
    if (currStepTotal < friend.initialStepCount) {
      // must have rebooted device
      await FriendDB().updateInitialStepCount(friend.identifier, 0);
      actualSteps = 0;
    } else {
      actualSteps = currStepTotal - friend.initialStepCount;
    }

    if (actualSteps >= friend.currentStepsGoal) {
      await _handleGoalCompleted(friend);
    }
  }
}

Future<Null> _handleGoalCompleted(Friend friend) async {
  await initNotification();
  await scheduleNudgeCompletedGoal(friend.name, friend.currentStepsGoal);

  // could separate this API code into a helper file
  final prefs = await SharedPreferences.getInstance();

  final data =
      json.encode({'type': 'nudge-completed', 'goal': friend.currentStepsGoal});
  final body = json.encode({
    'identifier_from': prefs.getString(USER_IDENTIFIER_KEY),
    'password': prefs.getString(USER_PASSWORD_KEY),
    'identifier_to': friend.identifier,
    'data': data
  });

  await http
      .post(
    Uri.parse(BASE_URL + "/user/nudge/new"),
    headers: {"Content-Type": "application/json"},
    body: body,
  )
      .then((response) {
    final body = json.decode(response.body);
    print(body);
  });

  await FriendDB().updateGoalFromFriend(friend.identifier, null, null);
}

void schedulePedometerInsert() {
  print("Cron executes background tasks");

  // final adToDBhour = 23;
  final addToDBhour = 23;
  final addToDBminute = 58;
  addDataToDB = Cron().schedule(
      Schedule.parse("$addToDBminute $addToDBhour * * 0-6"), () async {
    print("Schedule has been set");
    await _addStepsDaily();
  });
}

/// schedules a cron job to publish data
void schedulePublish() {
  // final day = DateTime.monday;
  // final hour = 12;
  // final minute = 0;
  final day = DateTime.wednesday;
  final hour = 12;
  final minute = 15;

  // This may help: https://crontab.guru/
  publishTask =
      Cron().schedule(Schedule.parse("$minute $hour * * $day"), () async {
    if (!await UserWellbeingDB().empty) {
      // publish if there is at least one wellbeing item saved
      _publishData();
    }
  });
}

void cancelPublish() {
  publishTask.cancel();
  publishTask = null;
}

/// This task needs to be scheduled every day at 23:58
void _addStepsDaily() async {
  final prefs = await SharedPreferences.getInstance();
  final pedometerPair = prefs.getStringList(PREV_PEDOMETER_PAIR_KEY);
  assert(pedometerPair.length == 2);
  final prevTotal = int.parse(pedometerPair.first);

  print("prevTotal: $prevTotal");

  final int currTotal = await Pedometer.stepCountStream.first
      .then((value) => value.steps)
      .catchError((_) => 0);

  print("currTotal: $currTotal");
  final actualSteps = prevTotal > currTotal ? currTotal : currTotal - prevTotal;
  print("actualSteps $actualSteps");
  if (await _checkIfDataExists()) {
    await updateData(numSteps: 8888);
    // await updateData(numSteps: actualSteps.toInt());
    print("Steps updated for ${DateTime.now().toIso8601String()}");
  } else {
    await insertData(numSteps: 8888);
    // await insertData(numSteps:actualSteps.toInt());
    print("Steps added for ${DateTime.now().toIso8601String()}");
  }

  ///Setting new value for the pedometer to count from
  prefs.setStringList(PREV_PEDOMETER_PAIR_KEY,
      [currTotal.toString(), DateTime.now().toIso8601String()]);
}

Future<bool> _checkIfDataExists() async {
  String checkDate = DateTime.now().toIso8601String().substring(0, 10);
  bool _dataAlreadyExists =
      await UserWellbeingDB().getDataAlreadyExists(checkDate: checkDate);
  return _dataAlreadyExists == true;
}

updateData({int numSteps}) async {
  int id = await UserWellbeingDB().update(
      columnId: 3,
      value: numSteps,
      Date: DateTime.now().toIso8601String().substring(0, 10));
  print("Record id updated: $id");
  return id;
}

insertData({int numSteps}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userPostcode = prefs.getString('postcode');
  String userSupportCode = prefs.getString('support_code');

  await UserWellbeingDB().insertWithData(
      date: DateTime.now().toIso8601String().substring(0, 10),
      postcode: userPostcode,
      numSteps: numSteps,
      wellbeingScore: null,
      sputumColour: null,
      mrcDyspnoeaScale: null,
      speechRate: null,
      speechRateTest: null,
      testDuration: null,
      audioURL: null,
      supportCode: userSupportCode);
}

/// TODO: Edit the query for publishing
void _publishData() async {
  /// Since we log the steps every day and allow the user to "add data"
  /// we will be getting last week worth of data
  print("Data Sent");
  // final items = await UserWellbeingDB().getLastNDaysAvailable(8);
  final items = await UserWellbeingDB().dataPastWeekToPublish();
  final item = items[0];

  /// Legacy code for "seeding accurate data 70% of the time
  // final int anonScore = _anonymizeScore(item.wellbeingScore);
  // int1/int2 is a double in dart
  // final double normalizedSteps =
  //     (item.numSteps / RECOMMENDED_STEPS_IN_WEEK) * 10.0;
  // final double errorRate = (normalizedSteps > anonScore)
  //     ? normalizedSteps - anonScore
  //     : anonScore - normalizedSteps;

  final body = jsonEncode({
    "postCode": item.postcode,
    "weeklySteps": item.numSteps,
    "wellbeingScore": item.wellbeingScore,
    "sputumColour": item.sputumColour,
    "mrcDyspnoeaScale": item.mrcDyspnoeaScale,
    // "errorRate": errorRate.truncate(),
    "supportCode": item.supportCode,
    "date_sent": item.date,

    ///N.B. The weeks are represented starting from monday of every week
  });

  print("Sending body $body");
  http
      .post(Uri.parse(BASE_URL + "/add-wellbeing-record"),
          headers: {"Content-Type": "application/json"}, body: body)
      .then((response) {
    print("Reponse status: ${response.statusCode}");
    print("Reponse body: ${response.body}");
    final asJson = jsonDecode(response.body);
    // could be null:
    if (asJson['success'] != true) {
      print("Something went wrong.");
    }
  });
}

/// Lies 30% of the time. Okay technically it lies 3/10 * 10/11 = 3/11 of the
/// time since there's a chance it could just pick the true score anyway
int _anonymizeScore(double score) {
  final random = Random();
  return (random.nextInt(100) > 69) ? random.nextInt(11) : score.truncate();
}
