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

import '../../main.dart';

const URL_USER_MANUAL =
    'https://uclcomputerscience.github.io/COMP0016_2020_21_Team26/'
    'pdfs/usermanual.pdf';

/// Displays current Wellbeing Score, steps and all aditional metircs this week
class WellbeingPage extends StatefulWidget {
  final List<CardClass> cards;
  final Stream<int> stepValueStream;
  const WellbeingPage({this.stepValueStream, this.cards});
  @override
  State<WellbeingPage> createState() => _WellbeingPageState();
}

class _WellbeingPageState extends State<WellbeingPage> {
  Future _futureLatestData;
  double lastWellbeingScore = 0;
  double lastSputumColour = 0;
  double lastmrcDyspnoeaScale = 0;
  double lastSpeechRate = 0;
  Stream currentStepValueStream;

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      print("didChangeDependencies got triggered");
      _futureLatestData = _getFutureLatestData();
      currentStepValueStream = widget.stepValueStream;
      super.didChangeDependencies();
    });
  }

  _getFutureLatestData() async {
    return await Provider.of<UserWellbeingDB>(context, listen: true)
        .getLastNWeeks(8);
  }

  /// true if we should display a banner to warn that we cannot access the
  /// pedometer
  bool pedometerWarn = false;

  final Future<int> _lastTotalStepsFuture = SharedPreferences.getInstance()
      .then((prefs) => prefs.getInt(PREV_STEP_COUNT_KEY));

  /// Wellbeing page tutorial keys tutorial keys
  // GlobalKey _lastWeekWBTutorialKey = GlobalObjectKey("laskweek_wb");
  // GlobalKey _stepsTutorialKey = GlobalObjectKey("steps");

  /// TODO: Add tutorial to the wellbeing page
  /// Card specific visualisations

  @override
  Widget build(BuildContext context) {
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
      Widget _defaultGraph([CardClass card]) {
        switch (card.cardId) {
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
        switch (card.cardId) {

          /// Wellbeing Circle
          case 1:
            lastItems.forEach((element) {
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
            lastItems.forEach((element) {
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
            lastItems.forEach((element) {
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
            lastItems.forEach((element) {
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
            future: _futureLatestData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final lastTotalSteps = snapshot.data;
                return StreamBuilder(
                  stream: currentStepValueStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final int currTotalSteps = snapshot.data;
                      final actualSteps = lastTotalSteps > currTotalSteps
                          ? currTotalSteps
                          : currTotalSteps - lastTotalSteps;
                      return CirclePercentIndicator(
                          color: card.color,
                          score: actualSteps,
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
                      return CirclePercentIndicator(
                          color: card.color, units: card.units);
                    }
                    return CircularProgressIndicator();
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
                    : _defaultGraph(card);
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
                    builder: (context) => ChartPage(card: widget.cards[index])),
              );
            },
          );
        });

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
