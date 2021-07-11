import 'package:flutter/material.dart';
import 'package:nudge_me/pages/wellbeing_page/cards.dart';
import 'package:nudge_me/pages/wellbeing_page/homePageGridView.dart';
import 'package:nudge_me/shared/wellbeing_graph.dart';

class WellbeingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Text("Wellbeing Diary",
                    style: Theme.of(context).textTheme.headline1),
              ),
              Flexible(
                child: HomePageGridView(cards: cards),
              ),

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
