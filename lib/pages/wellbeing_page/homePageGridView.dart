import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nudge_me/pages/wellbeing_page/cards.dart';
import 'package:nudge_me/pages/wellbeing_page/circle_progress.dart';
import 'package:nudge_me/pages/wellbeing_page/speech_rate_tile.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';

import '../charts_page/graph_page.dart';

class HomePageGridView extends StatelessWidget {
  final List<CardClass> cards;

  const HomePageGridView({Key key, this.cards}) : super(key: key);

  /// Return different visualisation for different card depending on card id
  Widget _getCardVisualisation(CardClass card) {
    switch (card.cardId) {

      /// Steps
      case 0:
        return CirclePercentIndicator(
            color: card.color, actualValue: 100, goal: 1000, units: card.units);

      /// Wellbeing Score
      case 1:
        return WellbeingCircle(
          score: card.score,
          width: 100,
          height: 100,
        );

      /// Sputum colour
      case 2:
        return WellbeingCircle(
            score: card.score,
            firstColor: card.color,
            secondColor: Colors.transparent,
            width: 100,
            height: 100);

      /// Breathlessness
      case 3:
        return CirclePercentIndicator(
            color: card.color, actualValue: card.score, goal: 10, units: "");

      /// Speech Rate
      case 4:
        return SpeechRareTile(card: card);

      default:
        return Text("Ops, something went wrong");
    }
  }

  /// Adjusting the size of the tiles
  /// Ref: https://stackoverflow.com/questions/53612200/flutter-how-to-give-height-to-the-childrens-of-gridview-builder
  @override
  Widget build(BuildContext context) {
    /// Building Grid View
    GridView homePageGridView = new GridView.builder(
        itemCount: cards.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / 1.65),
        ),
        itemBuilder: (BuildContext context, int index) {
          // print(cards[index].units);
          return GestureDetector(
            child: Card(
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.fromLTRB(8, 8, 8, 8),

              /// Padding for card contents
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          cards[index].cardIcon,
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                              child: Text(
                                cards[index].titleOfCard,
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
                    _getCardVisualisation(cards[index]),

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
                  builder: (context) => BarChartPage(card: cards[index]),
                ),
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => new BarChartPage(
              //       card: cards[index],
              //     ),
              //   ),
              // );
            },
          );
        });

    return homePageGridView;
  }
}
