import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nudge_me/background.dart';
import 'package:nudge_me/crypto.dart';
import 'package:nudge_me/main_pages.dart';
import 'package:nudge_me/model/friends_model.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/add_friend_page.dart';
import 'package:nudge_me/pages/contact_share_page.dart';
import 'package:nudge_me/pages/nudge_progress_page.dart';
import 'package:nudge_me/pages/send_nudge_page.dart';
import 'package:nudge_me/shared/friend_graph.dart';
import 'package:nudge_me/shared/generate_hashmap.dart';
import 'package:pointycastle/pointycastle.dart' as pointyCastle;

import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

/// NOTE: Members of the user's support network are referred to as 'friends' in the code.
/// This short form is fine for the code but it should not be called this on the user side.

/// get the latest messages for this user
/// returns true if there are new messages from a friend
Future<bool> getLatest([BuildContext ctx]) async {
  final friendDB = ctx == null ? FriendDB() : Provider.of<FriendDB>(ctx);
  final prefs = await SharedPreferences.getInstance();
  final body = jsonEncode({
    "identifier": prefs.getString(USER_IDENTIFIER_KEY),
    "password": prefs.getString(USER_PASSWORD_KEY),
  });
  stderr.writeln("body: $body");

  bool hasNewData = false;
  await http
      .post(Uri.parse(BASE_URL + "/user/message"),
          headers: {"Content-Type": "application/json"}, body: body)
      .then((response) async {
    print("Data Recieved: ${response.body}");
    // this typecast may cause an error if the password doesn't match, but
    // that shouldn't happen (and if it does I want it to be reported
    // anway). So I'm not doing any special error-handling.
    final List<dynamic> messages = jsonDecode(response.body);

    final pubKey = RSAKeyParser().parse(prefs.getString(RSA_PUBLIC_PEM_KEY))
        as pointyCastle.RSAPublicKey;
    final privKey = RSAKeyParser().parse(prefs.getString(RSA_PRIVATE_PEM_KEY))
        as pointyCastle.RSAPrivateKey;
    final encrypter = Encrypter(RSA(publicKey: pubKey, privateKey: privKey));

    if (messages.length > 0) {
      for (var message in messages) {
        String encrypted = message['data'];
        String decrypted = encrypter.decrypt64(encrypted);
        message['data'] = decrypted;
        print(decrypted);
      }
      await friendDB.updateWellbeingData(messages);
    }

    // If any of the messages are from a friend, there is new data:
    for (var message in messages) {
      if (await friendDB.isIdentifierPresent(message['identifier_from'])) {
        hasNewData = true;
        break;
      }
    }
  });
  return hasNewData;
}

class SupportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SupportPageState();
}

class SupportPageState extends State<SupportPage> {
  @override
  void initState() {
    super.initState();

    _networkRefresh();
  }

  Future<Null> _networkRefresh() async {
    // no point checking back-end if no friends in network
    if (!await Provider.of<FriendDB>(context, listen: false).empty) {
      getLatest();
      checkIfGoalsCompleted();
      refreshNudge(false);
    }
  }

  /// gets the friends list using provider.
  Future<List<Friend>> _getFriendsList(BuildContext context) =>
      Provider.of<FriendDB>(context).getFriends();

  /// Get message used to add friends.
  ///
  /// sends user to our website, which should redirect them to the
  /// nudgeme://... custom scheme (since many apps don't recognise them as
  /// links by default, we redirect them manually).
  Future<String> _getShareMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final identifier = prefs.getString(USER_IDENTIFIER_KEY);
    final pubKey = prefs.getString(RSA_PUBLIC_PEM_KEY);
    final url = "$BASE_URL/add-friend?"
        "identifier=${Uri.encodeComponent(identifier)}"
        "&pubKey=${Uri.encodeComponent(pubKey)}";
    return "Add me on NudgeShare by clicking this:\n$url";
  }

  List<Widget> _getShareLinkButtons() {
    final shareButton = OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor)),
        onPressed: () async => Share.share(await _getShareMessage()),
        child: Text("Share identity link",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)));
    final contactShareButton = OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor)),
        onPressed: () async => Share.share(await _getShareMessage()),
        //     () async {
        //   if (await Permission.contacts.request().isGranted) {
        //     final message = await _getShareMessage();
        //     return Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => ContactSharePage(message)));
        //   } else {
        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //         content: Text("Need permission to share with contacts.")));
        //   }
        // },
        child: Text("Share identity link \nusing SMS",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white)));

    return [shareButton, contactShareButton];
  }

  Widget _getQRCode(String identifier, String pubKey) {
    return Container(
      width: 200,
      height: 200,
      child: QrImage(
        data: "$identifier\n$pubKey",
        version: QrVersions.auto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendsList = _getFriendsList(context);

    Provider.of<FriendDB>(context)
        .getFriends()
        .then((value) => print("value:$value"));
    // NOTE: since we are using nested Scaffolds (there is one above this), we need
    // to wrap a ScaffoldMessenger in between them to avoid showing duplicate
    // snackbars, or rather, to avoid getting an exception since we were *about*
    // to display duplicate snackbars.
    // In particular, the exception would occur when you show a snackbar (using the context)
    // and then you pop off the navigator.
    return ScaffoldMessenger(
      child: Scaffold(
        body: FutureBuilder(
          future: friendsList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Friend> friends = snapshot.data;
              friends.sort();
              return _getLoadedPage(context, friends);
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("Error when retrieving network.");
            }
            return LinearProgressIndicator();
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _getLoadedPage(BuildContext context, List<Friend> friends) {
    final scanCodeButton = OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.secondary)),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                // NOTE: not using the new context 'ctx'
                builder: (ctx) => AddFriendPage())),
        child: Text(
          'Scan code to\n add to network',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ));
    final showKeyButton = OutlinedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.secondary)),
        onPressed: () => showDialog(
            builder: (context) => AlertDialog(
                  scrollable: true,
                  title: Text("My NudgeShare Identity \n(QR Code)",
                      textAlign: TextAlign.center),
                  content: FutureBuilder(
                    future: SharedPreferences.getInstance(),
                    builder: (context, data) {
                      if (data.hasData) {
                        final SharedPreferences prefs = data.data;
                        final identifier = prefs.getString(USER_IDENTIFIER_KEY);
                        final pubKey = prefs.getString(RSA_PUBLIC_PEM_KEY);
                        return Column(children: [
                          _getQRCode(identifier, pubKey),
                          Text(
                              "This is your identity code.\n\n For someone to add you to their support network, ask them to:\n ",
                              style: Theme.of(context).textTheme.bodyText2,
                              textAlign: TextAlign.center),
                          Text(
                              "1. Open their NudgeShare app and navigate to the Network page.\n" +
                                  "2. Click ???Scan code to add to network.???\n" +
                                  "3. Using the camera on their phone, scan your code.\n" +
                                  "4. Once they have added you, add them back by clicking on the ???Scan code to add to network??? button.",
                              style: Theme.of(context).textTheme.bodyText2)
                        ]);
                      } else if (data.hasError) {
                        print(data.error);
                        return Text("Couldn't get data.");
                      }
                      return LinearProgressIndicator();
                    },
                  ),
                  actions: [
                    TextButton(
                      child: Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
            context: context),
        child: Text(
          'My Identity \nCode',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ));
    final shareLinkButtons = _getShareLinkButtons();
    final buttons = shareLinkButtons + [showKeyButton, scanCodeButton];

    final noFriendsWidget = Column(children: [
      Center(
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(children: [
                RichText(
                    text: new TextSpan(children: [
                      new TextSpan(
                          text: "With NudgeShare, caring is sharing. \n\n" +
                              "Let people in your care network know how you are. You can start this process by texting them a link to download NudgeShare.\n",
                          style: Theme.of(context).textTheme.bodyText2),
                    ]),
                    textAlign: TextAlign.center),
                //share button for link to download app
                RichText(
                    text: new TextSpan(children: [
                      new TextSpan(
                          text: "Share the link using one of these buttons:",
                          style: Theme.of(context).textTheme.bodyText2)
                    ]),
                    textAlign: TextAlign.center),
                SizedBox(height: 20)
              ]))),
      shareLinkButtons[0],
      shareLinkButtons[1],
      SizedBox(height: 20),
      Center(
          child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: RichText(
                  text: new TextSpan(children: [
                    new TextSpan(
                        text:
                            "When you both have NudgeShare, you can send your wellbeing diary to people who care for you and they can do the same with you.",
                        style: TextStyle(
                            fontFamily: "Rosario",
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    new TextSpan(
                        text:
                            " Hopefully, this will  start a conversation about wellbeing that is meaningful and helpful.",
                        style: TextStyle(
                            fontFamily: "Rosario",
                            fontSize: 15,
                            color: Colors.black)),
                    new TextSpan(
                        text:
                            "\n\n\nAlternatively, add people to your care network in person by scanning their QR code and having them scan yours.",
                        style: TextStyle(
                            fontFamily: "Rosario",
                            fontSize: 13,
                            color: Colors.black))
                  ]),
                  textAlign: TextAlign.center))),
      SizedBox(height: 5),
      showKeyButton,
      scanCodeButton,
    ]);
    final friendsDescription = Padding(
        padding: EdgeInsets.fromLTRB(5, 65, 5, 0),
        child: RichText(
            text: new TextSpan(children: [
              TextSpan(
                  text: "With NudgeShare, caring is sharing. \n\n",
                  style: Theme.of(context).textTheme.bodyText2),
              TextSpan(
                  text:
                      "Let people in your care network know how you are to start meaningful and helpful conversations about wellbeing. \n\n",
                  style: Theme.of(context).textTheme.bodyText2),
              TextSpan(children: [
                TextSpan(
                    text: "Click the ",
                    style: Theme.of(context).textTheme.bodyText2),
                TextSpan(
                    text: "send button below ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text: "to ", style: Theme.of(context).textTheme.bodyText2),
                TextSpan(
                    text: "share your wellbeing diary ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text: "with your network or to ",
                    style: Theme.of(context).textTheme.bodyText2),
                TextSpan(
                    text: "send a nudge. ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
              ]),
              TextSpan(
                  text:
                      "Sending a nudge to someone in your care network allows you to set them a steps goal. ",
                  style: Theme.of(context).textTheme.bodyText2),
              TextSpan(children: [
                TextSpan(
                    text:
                        "\nView your network???s wellbeing diaries and nudges with the ",
                    style: Theme.of(context).textTheme.bodyText2),
                TextSpan(
                    text: "View button.",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black))
              ]),
              TextSpan(
                  text: "\n\nPull down to reload.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
            ]),
            textAlign: TextAlign.center));

    return friends.length == 0
        ? noFriendsWidget
        : LiquidPullToRefresh(
            //showChildOpacityTransition: false,
            onRefresh: () => getLatest(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  brightness: Brightness.light,
                  pinned: true,
                  backgroundColor: Colors.white,
                  expandedHeight: 350,
                  title: Text(
                    "Support Network",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: friendsDescription,
                    collapseMode: CollapseMode.none,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Divider(),
                ),
                // arranges buttons in a grid
                SliverPadding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  sliver: SliverGrid.count(
                    childAspectRatio: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    crossAxisCount: 2,
                    children: buttons,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Divider(),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, i) => getListTile(context, friends[i]),
                      childCount: friends.length),
                ),
              ],
            ),
          );
  }

  /// Modal to select which wellbeing data to share
  Future<void> _showWellbeingSendDialog(
      BuildContext context, Friend friend) async {
    final List<WellbeingItem> dataFromDB =
        await UserWellbeingDB().getOverallTrendsForPastNWeeks(5);
    return await showDialog(
        context: context,
        builder: (context) {
          bool _exportSteps = false;
          bool _exportWellbeing = false;
          bool _exportBreathlessness = false;
          bool _exportSputumColor = false;
          bool _exportOverallTrends = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Share Preferences",
                style: Theme.of(context).textTheme.headline2,
              ),

              /// Timeframe selection
              content: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /// Selection of what data to export
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Select Data to Export\n(Past Month)",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CheckboxListTile(
                        title:
                            const Text('Steps', style: TextStyle(fontSize: 16)),
                        value: _exportSteps,
                        onChanged: (bool value) {
                          setState(() {
                            _exportSteps = !_exportSteps;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Wellbeing Score',
                            style: TextStyle(fontSize: 16)),
                        value: _exportWellbeing,
                        onChanged: (bool value) {
                          setState(() {
                            _exportWellbeing = !_exportWellbeing;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Sputum Color',
                            style: TextStyle(fontSize: 16)),
                        value: _exportSputumColor,
                        onChanged: (bool value) {
                          setState(() {
                            _exportSputumColor = !_exportSputumColor;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('MRC Dyspnoea Scale Score',
                            style: TextStyle(fontSize: 16)),
                        value: _exportBreathlessness,
                        onChanged: (bool value) {
                          setState(() {
                            _exportBreathlessness = !_exportBreathlessness;
                          });
                        },
                      ),
                      (dataFromDB.length < 5)
                          ? SizedBox.shrink()
                          : CheckboxListTile(
                              title: const Text('Overall Trends (Past 5 weeks)',
                                  style: TextStyle(fontSize: 16)),
                              value: _exportOverallTrends,
                              onChanged: (bool value) {
                                setState(() {
                                  _exportOverallTrends = !_exportOverallTrends;
                                });
                              },
                            )
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                SimpleDialogOption(
                  onPressed: () async {
                    if ((_exportSteps ||
                        _exportWellbeing ||
                        _exportBreathlessness ||
                        _exportSputumColor ||
                        _exportOverallTrends)) {
                      ///TODO Add a call to function to share data

                      _sendWellbeingData(
                          context,
                          friend,
                          _exportSteps,
                          _exportWellbeing,
                          _exportSputumColor,
                          _exportBreathlessness,
                          _exportOverallTrends);
                    }
                  },
                  child: const Text('Export'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"))
              ],
            );
          });
        });
  }

  Future<Null> _pushGoalPage(BuildContext context, Friend friend) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (context) => SendNudgePage(friend)));
  }

  /// Modal to select what to do you what to send: a nudge or wellbeing data
  Widget getListTile(BuildContext context, Friend friend) {
    final sendOptionsDialog = SimpleDialog(
      title: const Text("Choose what to send"),
      children: [
        SimpleDialogOption(
          child: const Text("???? Send Your Wellbeing Data"),
          onPressed: () {
            Navigator.pop(context);
            _showWellbeingSendDialog(context, friend);
          },
        ),
        SimpleDialogOption(
          child: Text("??? Set ${friend.name} a Step Goal"),
          onPressed: () {
            Navigator.pop(context);
            if (friend.sentActiveGoal == 1) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                            'You have already sent a goal, sending another will delete their previous. Continue?'),
                        actions: [
                          TextButton(
                              child: Text('No'),
                              onPressed: () => Navigator.pop(context)),
                          TextButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.pop(context);
                                _pushGoalPage(context, friend);
                              }),
                        ],
                      ));
            } else {
              _pushGoalPage(context, friend);
            }
          },
        ),
      ],
    );

    final onViewWellbeing = () {
      Provider.of<FriendDB>(context, listen: false).setRead(friend.identifier);
      return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text("Shared Data"),
                content: FriendGraph(Provider.of<FriendDB>(context)
                    .getLatestData(friend.identifier)),
                actions: [
                  TextButton(
                    child: Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    };
    final viewOptionsDialog = SimpleDialog(
      title: const Text("Choose what to view"),
      children: [
        SimpleDialogOption(
          child: Text("???? Wellbeing Data from ${friend.name}"),
          onPressed: onViewWellbeing,
        ),
        SimpleDialogOption(
          child: Text("???? Step Goal from ${friend.name}"),
          onPressed: () {
            Navigator.pop(context);
            if (friend.currentStepsGoal != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NudgeProgressPage(friend)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.yellow,
                  content:
                      Text("${friend.name} has not sent you any goal yet.")));
            }
          },
        )
      ],
    );

    final onView = () =>
        showDialog(context: context, builder: (context) => viewOptionsDialog);
    final viewButton = OutlinedButton(onPressed: onView, child: Text("View"));

    // friend.read might be null
    final unread = friend.read == 0;
    print("friend.name: ${friend.name}");
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      child: ListTile(
        leading: unread ? Icon(Icons.message) : Icon(Icons.person),
        selected: unread,
        title: Text(friend.name),
        onTap: onView,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            viewButton,
            SizedBox(
              width: 5,
            ),
            ElevatedButton(
                onPressed: () => showDialog(
                    context: context, builder: (context) => sendOptionsDialog),
                child: const Text("Send")),
          ],
        ),
      ),
      actions: [
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => Provider.of<FriendDB>(context, listen: false)
              .deleteFriend(friend),
        )
      ],
    );
  }

  /// Edit this function to get appropriate data
  Future<void> _sendWellbeingData(
      BuildContext context,
      Friend friend,
      bool exportSteps,
      bool exportWellbeing,
      bool exportSputumColor,
      bool exportBreathlessness,
      bool exportOverallTrends) async {
    final friendKey =
        RSAKeyParser().parse(friend.publicKey) as pointyCastle.RSAPublicKey;

    String timeMonthYear;
    Map<String, List<double>> dataHashMap = generateMonthlyHashMapExport();
    print(dataHashMap);
    timeMonthYear = 'W';

    List<int> cardIds = [];
    List<int> queryIds = [];

    if (exportOverallTrends) {
      queryIds.addAll([0, 1, 2, 3]);
    }
    if (exportSteps) {
      cardIds.add(0);
      if (!queryIds.contains(0)) {
        queryIds.add(0);
      }
    }
    if (exportWellbeing) {
      cardIds.add(1);
      if (!queryIds.contains(1)) {
        queryIds.add(1);
      }
    }
    if (exportSputumColor) {
      cardIds.add(2);
      if (!queryIds.contains(2)) {
        queryIds.add(2);
      }
    }
    if (exportBreathlessness) {
      cardIds.add(3);
      if (!queryIds.contains(3)) {
        queryIds.add(3);
      }
    }

    double doubuleToTwoSf(double number) {
      return double.parse(number.toStringAsFixed(2));
    }

    exportAllData(
        Map<String, List<double>> hashMap, List<WellbeingItem> dataFromDB) {
      dataFromDB.forEach((wellbeingItem) {
        String matchDate = wellbeingItem.date;
        DateTime dateFromDb = DateTime.parse(wellbeingItem.date);

        if (dateFromDb.weekday != 1) {
          matchDate = dateFromDb
              .subtract(Duration(days: dateFromDb.weekday - 1))
              .toIso8601String()
              .substring(0, 10);
        } else {
          matchDate = dateFromDb.toIso8601String().substring(0, 10);
        }

        hashMap[matchDate]
          ..addAll([
            doubuleToTwoSf((wellbeingItem.numSteps == null)
                ? 0
                : wellbeingItem.numSteps / 1000),
            doubuleToTwoSf((wellbeingItem.wellbeingScore == null)
                ? 0
                : wellbeingItem.wellbeingScore),
            doubuleToTwoSf((wellbeingItem.sputumColour == null)
                ? 0
                : wellbeingItem.sputumColour),
            doubuleToTwoSf((wellbeingItem.mrcDyspnoeaScale == null)
                ? 0
                : wellbeingItem.mrcDyspnoeaScale)
          ]);
      });

      return hashMap;
    }

    final List<WellbeingItem> dataFromDB = await UserWellbeingDB()
        .getLastMonthYearSpecificColumns(
            ids: queryIds.map((e) => e + 3).toList(), timeframe: timeMonthYear);

    if (exportOverallTrends ||
        (exportSteps &
            exportWellbeing &
            exportSputumColor &
            exportBreathlessness)) {
      print("exportAllData got triggered");
      dataHashMap = exportAllData(dataHashMap, dataFromDB);
    } else {
      cardIds.forEach((id) {
        switch (id) {
          case 0:
            dataHashMap = populateWeeklyHashMapWithDataFromDB(
                dataHashMap, dataFromDB, id);
            return dataHashMap;
          case 1:
            dataHashMap = populateWeeklyHashMapWithDataFromDB(
                dataHashMap, dataFromDB, id);
            return dataHashMap;
          case 2:
            dataHashMap = populateWeeklyHashMapWithDataFromDB(
                dataHashMap, dataFromDB, id);
            return dataHashMap;
          case 3:
            dataHashMap = populateWeeklyHashMapWithDataFromDB(
                dataHashMap, dataFromDB, id);
            return dataHashMap;
          case 4:
        }
      });
    }

    if (exportOverallTrends) {
      cardIds.add(5);
    }

    /// Forming JSON
    final Map<String, String> mapped = {
      'ids': cardIds.toString(),
      'data': json.encode(dataHashMap)
    };

    final jsonString = json.encode(mapped);

    ///Encrypting JSON
    final encrypter = Encrypter(RSA(publicKey: friendKey));
    final data = encrypter.encrypt(jsonString).base64;
    final prefs = await SharedPreferences.getInstance();
    final body = json.encode({
      'identifier_from': prefs.getString(USER_IDENTIFIER_KEY),
      'password': prefs.getString(USER_PASSWORD_KEY),
      'identifier_to': friend.identifier,
      'data': data
    });

    http
        .post(Uri.parse(BASE_URL + "/user/message/new"),
            headers: {"Content-Type": "application/json"}, body: body)
        .then((response) {
      final body = json.decode(response.body);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 10,
          backgroundColor:
              (body['success'] == false) ? Colors.red : Colors.green,
          content: body['success'] == false
              ? Text("Failed to send.")
              : Text("Sent data to ${friend.name}.")));
    });
  }
}
