import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/pages/wellbeing_page/circle_progress.dart';
import 'package:nudge_me/pages/wellbeing_page/speech_rate_tile.dart';
import 'package:nudge_me/shared/wellbeing_circle.dart';

import '../charts_page/graph_page.dart';

class WellbeingPageGridView extends StatefulWidget {
  final List<CardClass> cards;
  final Stream<int> stepValueStream;

  const WellbeingPageGridView({Key key, this.cards, this.stepValueStream})
      : super(key: key);

  @override
  State<WellbeingPageGridView> createState() => _WellbeingPageGridViewState();
}

class _WellbeingPageGridViewState extends State<WellbeingPageGridView> {
  /// Return different visualisation for different card depending on card id
  Widget _getCardVisualisation(CardClass card) {
    switch (card.cardId) {

      /// Steps
      case 0:
        return CirclePercentIndicator(color: card.color, units: card.units);

      /// Wellbeing Score
      case 1:
        return WellbeingCircle();

      /// Sputum colour
      case 2:
        return WellbeingCircle(
            firstColor: card.color, secondColor: Colors.transparent);

      /// Breathlessness
      case 3:
        return CirclePercentIndicator(color: card.color, goal: 10, units: "");

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
    GridView wellbeingPageGridView = new GridView.builder(
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

                    //Padding(
                    //                       padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                    //                       child: _getCardVisualisation(cards[index]),
                    //                     ),
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

    return Flexible(child: wellbeingPageGridView);
  }
}
