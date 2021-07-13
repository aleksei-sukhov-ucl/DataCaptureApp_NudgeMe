import 'package:flutter/material.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/pages/charts_page/graph_page.dart';
import 'package:nudge_me/pages/wellbeing_page/cards.dart';
import 'package:nudge_me/pages/wellbeing_page/circle_progress.dart';
import 'package:nudge_me/pages/wellbeing_page/speech_rate_tile.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

/// Displays current Wellbeing Score, steps and all aditional metircs this week
class WellbeingPage extends StatefulWidget {
  final List<CardClass> cards;
  final Stream<int> stepValueStream;
  const WellbeingPage({this.stepValueStream, this.cards});
  @override
  State<WellbeingPage> createState() => _WellbeingPageState();
}

class _WellbeingPageState extends State<WellbeingPage> {
  /// true if we should display a banner to warn that we cannot access the
  /// pedometer
  bool pedometerWarn = false;

  final Future<int> _lastTotalStepsFuture = SharedPreferences.getInstance()
      .then((prefs) => prefs.getInt(PREV_STEP_COUNT_KEY));

  /// Wellbeing page tutorial keys tutorial keys
  GlobalKey _lastWeekWBTutorialKey = GlobalObjectKey("laskweek_wb");
  GlobalKey _stepsTutorialKey = GlobalObjectKey("steps");

  /// TODO: Add tutorial to the wellbeing page
  /// Card specific visualisations
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
        default:
          return Text("Oops,\nthis should not\nhave happened!");
      }
    }

    Widget _dataGraph({CardClass card, WellbeingItem lastItemList}) {
      switch (card.cardId) {
        case 1:

          /// Wellbeing Circle
          return WellbeingCircle(
            score: lastItemList.wellbeingScore.truncate(),
          );
        case 2:

          /// Sputum Colour
          return WellbeingCircle(
              score: lastItemList.sputumColour.truncate(),
              firstColor: card.color,
              secondColor: Colors.transparent);
        case 3:

          /// MRC Dyspnoea Scale
          return CirclePercentIndicator(
              score: lastItemList.mrcDyspnoeaScale.truncate(),
              color: card.color,
              goal: 10,
              units: "");
        case 4:

          /// Speech Rate
          return SpeechRareTile(score: lastItemList.speechRate.truncate());
        default:
          return Text("Oops,\nthis should not\nhave happened!");
      }
    }

    if (card.cardId == 0) {
      return FutureBuilder(
          key: _stepsTutorialKey,
          future: _lastTotalStepsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final lastTotalSteps = snapshot.data;
              return StreamBuilder(
                stream: widget.stepValueStream,
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
          future: Provider.of<UserWellbeingDB>(context).getLastNWeeks(1),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<WellbeingItem> lastItemList = snapshot.data;
              return lastItemList.isNotEmpty
                  ? _dataGraph(card: card, lastItemList: lastItemList[0])
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

  @override
  Widget build(BuildContext context) {
    /// Pop-up banner (widget) to notify of the pedometer not working
    final Widget warningBanner = MaterialBanner(
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
                  builder: (context) => BarChartPage(card: widget.cards[index]),
                ),
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
                child: Text("Wellbeing Diary",
                    style: Theme.of(context).textTheme.headline1),
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
