import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter/material.dart';
import 'package:nudge_me/shared/bar_graph_shared.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:nudge_me/shared/line_graph_shared.dart';

/// [StatelessWidget] that behaves very similarly to [WellbeingGraph].
/// It mainly parses and interprets the wellbeing data differently. Also there
/// are slight visual differences.

/// NOTE: Members of the user's support network are referred to as 'friends' in the code.
class FriendGraph extends StatelessWidget {
  /// json encoded [String] that can be decoded to get the the data
  final Future<String> friendData;

  final animate;

  const FriendGraph(this.friendData, {this.animate = true});

  @override
  Widget build(BuildContext context) {
    final keyCardForLineGraph = Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.grey[100],
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trends",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //   const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  //   child: Row(
                  //     children: [
                  //       Text(
                  //           showEndDate(
                  //               cardId: widget.card.cardId,
                  //               initialIndex: initialIndex),
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .bodyText2),
                  //       Icon(Icons.arrow_forward),
                  //       Text(
                  //           DateFormat.yMMMMd('en_US')
                  //               .format(DateTime.now()),
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .bodyText2),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    child: Expanded(
                      child: cards[4].cardDescription,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return FutureBuilder(
      future: friendData,
      builder: (ctx, dat) {
        if (dat.hasData) {
          String data = dat.data;
          if (data == "") {
            return Text("They haven't sent you anything.");
          }
          List<Widget> graphs = [];
          Map<String, dynamic> dataReceived = jsonDecode(data);

          final List<dynamic> ids = jsonDecode(dataReceived['ids']).toList();
          final Map<String, dynamic> rawDataForBarchart =
              json.decode(dataReceived['data']);

          List<int> zeros = List.filled(ids.length, 0);
          rawDataForBarchart.forEach((key, value) {
            if (value.isEmpty) {
              rawDataForBarchart[key] = zeros;
            }
          });

          ///Check if all data export exists
          int idsLength;
          if (ids.contains(5)) {
            idsLength = ids.length - 1;
          } else {
            idsLength = ids.length;
          }

          if (ids.contains(5)) {
            Map<String, List<double>> hashMapForBarChart = {};

            rawDataForBarchart.forEach((key, value) {
              hashMapForBarChart[key] =
                  List<double>.from(rawDataForBarchart[key]);
            });
            graphs.add(
                LineChartTrendsShared(hashMapForLineChart: hashMapForBarChart));
            graphs.add(keyCardForLineGraph);
          }

          if (ids.contains(0) ||
              ids.contains(1) ||
              ids.contains(2) ||
              ids.contains(3)) {
            for (var i = 0; i < idsLength; i++) {
              Map<String, double> hashMapForBarChart = {};
              rawDataForBarchart.forEach((key, value) {
                if (ids.contains(5)) {
                  hashMapForBarChart[key] =
                      double.parse(value[ids[i]].toString());
                } else {
                  hashMapForBarChart[key] = double.parse(value[i].toString());
                }
              });

              graphs.add(SharedBarChart(
                  cardId: ids[i],
                  hashMapForBarChart: hashMapForBarChart,
                  card: cards[ids[i]]));
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            width: MediaQuery.of(context).size.width * 0.95,
            child: ListView.builder(
                itemCount: graphs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: graphs[index]);
                }),
          );
        } else if (dat.hasError) {
          print(dat.error);
          return Text("Couldn't load graph.");
        }
        return LinearProgressIndicator();
      },
    );
  }
}
