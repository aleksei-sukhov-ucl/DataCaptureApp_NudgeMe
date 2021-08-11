import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/graph_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/shared/circle_progress.dart';
import 'package:nudge_me/pages/wellbeing_page/speech_rate_tile.dart';
import 'package:nudge_me/pages/wellbeing_page/trends_tile.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../background.dart';
import '../../main.dart';

const URL_USER_MANUAL =
    'https://uclcomputerscience.github.io/COMP0016_2020_21_Team26/'
    'pdfs/usermanual.pdf';

/// Displays current Wellbeing Score, steps and all aditional metircs this week
class WellbeingPage extends StatefulWidget {
  final List<CardClass> cards;
  final Stream<int> currentStepValueStream;
  const WellbeingPage({this.currentStepValueStream, this.cards});
  @override
  State<WellbeingPage> createState() => _WellbeingPageState();
}

class _WellbeingPageState extends State<WellbeingPage> {
  Future _futureLatestData;
  double lastWellbeingScore = 0;
  double lastSputumColour = 0;
  double lastmrcDyspnoeaScale = 0;
  double lastSpeechRate = 0;

  /// true if we should display a banner to warn that we cannot access the
  /// pedometer
  bool pedometerWarn = false;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      /// TODO: DELETE THIS
      _getAllshared();
      // schedulePedometerInsert();
      print("didChangeDependencies got triggered");
      _futureLatestData = _getFutureLatestData();
      super.didChangeDependencies();
    });
  }

  /// TODO: DELETE THIS
  _getAllshared() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final prefsMap = Map<String, dynamic>();
    for (String key in keys) {
      prefsMap[key] = prefs.get(key);
    }

    prefsMap.forEach((key, value) {
      print("key: $key | value: $value");
    });
  }

  _getFutureLatestData() async {
    return await Provider.of<UserWellbeingDB>(context, listen: true)
        .getLastNDaysAvailable(8);
  }

  final Future<List<String>> _lastTotalStepsFuture =
      SharedPreferences.getInstance()
          .then((prefs) => prefs.getStringList(PREV_PEDOMETER_PAIR_KEY));

  /// Wellbeing page tutorial keys tutorial keys
  // GlobalKey _lastWeekWBTutorialKey = GlobalObjectKey("laskweek_wb");
  // GlobalKey _stepsTutorialKey = GlobalObjectKey("steps");

  /// TODO: Add tutorial to the wellbeing page
  /// Card specific visualisations

  @override
  Widget build(BuildContext context) {
    // print("05 11 * * 0 - 6");
    // print("Current Date and time: ${DateTime.now()}");
    // Provider.of<UserWellbeingDB>(context).getLastNWeeks(8).then((items) {
    //   double maxSpeehRate = 0.0;
    //   items.reversed.forEach((element) {
    //     if (element.wellbeingScore != null) {
    //       maxSpeehRate = element.wellbeingScore;
    //     }
    //   });
    //
    //   print("maxSpeehRate: $maxSpeehRate");
    // });

    /// Pop-up banner (widget) to notify of the pedometer not working
    final Widget warningBanner = MaterialBanner(
      backgroundColor: Colors.white,
      leading: Icon(
        Icons.warning,
        color: Colors.red,
      ),
      content:
          const Text('No pedometer available. Functionality will be limited.'),
      actions: [
        TextButton(
          child: Text('Ok'),
          onPressed: () => setState(() => pedometerWarn = false),
        )
      ],
    );

    Widget _getCardVisualisation(CardClass card) {
      ///Returning Default "N/A" graphs in case of Future fails
      Widget _defaultGraph([int cardId]) {
        switch (cardId) {
          case 0:
            return CirclePercentIndicator(color: card.color);
          case 1:
            return WellbeingCircle();
          case 2:
            return WellbeingCircle(
                firstColor: card.color, secondColor: Colors.transparent);
          case 3:
            return CirclePercentIndicator(color: card.color);
          case 4:
            return SpeechRareTile();
          case 5:
            return LineChartTile();
          default:
            return Text("Oops,\nthis should not\nhave happened!");
        }
      }

      // if (element.wellbeingScore != null) {
      //   maxSpeehRate = element.wellbeingScore;
      // }

      Widget _dataGraph({CardClass card, List<WellbeingItem> lastItems}) {
        final lastItemsList = lastItems.reversed;
        switch (card.cardId) {

          /// Wellbeing Circle
          case 1:
            lastItemsList.forEach((element) {
              if (element.wellbeingScore != null) {
                lastWellbeingScore = element.wellbeingScore;
              }
            });
            print("print(lastWellbeingScore): $lastWellbeingScore");
            return WellbeingCircle(
              score: lastWellbeingScore.truncate(),
            );

          /// Sputum Colour
          case 2:
            lastItemsList.forEach((element) {
              if (element.sputumColour != null) {
                lastSputumColour = element.sputumColour;
              }
            });
            print("lastSputumColour: $lastSputumColour");
            return WellbeingCircle(
                score: lastSputumColour.truncate(),
                firstColor: card.color,
                secondColor: Colors.transparent);

          /// MRC Dyspnoea Scale
          case 3:
            lastItemsList.forEach((element) {
              if (element.mrcDyspnoeaScale != null) {
                lastmrcDyspnoeaScale = element.mrcDyspnoeaScale;
              }
            });
            return CirclePercentIndicator(
                score: lastmrcDyspnoeaScale.truncate(),
                color: card.color,
                goal: 5,
                units: "");

          /// Speech Rate
          case 4:
            lastItemsList.forEach((element) {
              if (element.speechRate != null) {
                lastSpeechRate = element.speechRate;
              }
            });

            return SpeechRareTile(score: lastSpeechRate.truncate());
          case 5:
            return LineChartTile();
          default:
            return Text("Oops,\nthis should not\nhave happened!");
        }
      }

      if (card.cardId == 0) {
        return FutureBuilder(
            // key: _stepsTutorialKey,
            future: _lastTotalStepsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print("snapshot.hasData");
                final lastTotalSteps = int.parse(snapshot.data.first);
                return StreamBuilder(
                  stream: widget.currentStepValueStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print("Card.cardId == 0 Snapshot has data!");
                      final int currTotalSteps = snapshot.data;

                      print("currTotalSteps: $currTotalSteps");
                      print("lastTotalSteps: $lastTotalSteps");

                      final actualSteps = lastTotalSteps > currTotalSteps
                          ? currTotalSteps
                          : currTotalSteps - lastTotalSteps;
                      return CirclePercentIndicator(
                          color: card.color,
                          score: actualSteps,
                          goal: 10000,
                          units: card.units);
                      // return Text(actualSteps.toString());
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      // NOTE: we do not have to worry about using setState here
                      // since whenever it builds it will execute this first and
                      // then the [Visibility] banner widget. Therefore, there is
                      // no case where the pedometer throws an error but no
                      // banner is shown.
                      pedometerWarn = true;
                      print("Circular process indicator for the error....");
                      return CirclePercentIndicator(
                          color: card.color, units: card.units);
                    } else {
                      print("Pedometer is working");
                      return _defaultGraph(card.cardId);
                    }
                  },
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Error");
              }
              return CircularProgressIndicator();
            });
      } else {
        return FutureBuilder(
            future: _futureLatestData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<WellbeingItem> lastItemList = snapshot.data;
                return lastItemList.isNotEmpty
                    ? _dataGraph(card: card, lastItems: lastItemList)
                    : _defaultGraph(card.cardId);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Something went wrong.",
                    style: Theme.of(context).textTheme.bodyText1);
              }
              return CircularProgressIndicator();
            });
      }
    }

    /// GridView for tiles
    final GridView _homePageGridView = new GridView.builder(
        itemCount: widget.cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 1.7),
        ),
        itemBuilder: (BuildContext context, int index) {
          // print(cards[index].units);
          return GestureDetector(
            child: Card(
              shadowColor: Theme.of(context).primaryColor,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.fromLTRB(8, 8, 8, 8),

              /// Padding for card contents
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          widget.cards[index].cardIcon,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                              child: Text(
                                widget.cards[index].titleOfCard,
                                style:
                                    Theme.of(context).textTheme.bodyText2.merge(
                                          TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      height: 40,
                    ),

                    /// Padding for visualisation
                    _getCardVisualisation(widget.cards[index]),

                    ///"View more >" text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'View More',
                          style: TextStyle(fontSize: 8),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 8,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChartPage(card: widget.cards[index]),
                ),
              );
            },
          );
        });

    schedulePublish();

    // UserWellbeingDB().dataPastWeekToPublish().then((items) {
    //   print(UserWellbeingDB);
    //   final item = items.first;
    //   print("UserWellbeingDB().dataPastWeekToPublish(): $item");
    //   final body = jsonEncode({
    //     "postCode": item.postcode,
    //     "weeklySteps": item.numSteps,
    //     "wellbeingScore": item.wellbeingScore,
    //     "sputumColour": item.sputumColour,
    //     "mrcDyspnoeaScale": item.mrcDyspnoeaScale,
    //     // "errorRate": errorRate.truncate(),
    //     "supportCode": item.supportCode,
    //     "date_sent": item.date,
    //
    //     ///N.B. The weeks are represented starting from monday of every week
    //   });
    //
    //   print("Sending body $body");
    // });

    return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("NudgeMe",
                        style: Theme.of(context).textTheme.headline1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
                      child: IconButton(
                        onPressed: () => launch(URL_USER_MANUAL),
                        icon: Icon(Icons.help_outline),
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: pedometerWarn == true,
                child: warningBanner,
              ),
              Flexible(child: _homePageGridView),

              /// Legacy Wellbeing Graph
              // WellbeingGraph(
              //   animate: true,
              // ),
            ]),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }
}
