import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:intl/intl.dart';
import 'package:nudge_me/shared/loading_indicator.dart';
import 'package:provider/provider.dart';

class LineChartTrends extends StatefulWidget {
  final CardClass card;
  final int initialIndex;
  const LineChartTrends({Key key, this.card, this.initialIndex})
      : super(key: key);

  @override
  _LineChartTrendsState createState() => _LineChartTrendsState();
}

class _LineChartTrendsState extends State<LineChartTrends> {
  // Future _futureTrends;
  //
  // @override
  // initState() {
  //   super.initState();
  //   _futureTrends = _getFutureTrends();
  // }
  final double barWidth = 4;

  Future<List<WellbeingItem>> _getFutureTrends() async {
    return await Provider.of<UserWellbeingDB>(context, listen: true)
        .getOverallTrendsForPastFourMonth();
  }

  LineChartData lineChartData({data, minX, maxX, interval}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {
          // print("touchResponse: ${touchResponse.lineBarSpots}");
        },
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
      ),

      /// X axis
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
            showTitles: false,
            reservedSize: 12,
            getTextStyles: (value) => TextStyle(
                  color: Color.fromRGBO(1, 1, 1, 1),
                  fontSize: 12,
                ),
            margin: 10,
            getTitles: (value) {
              // print(value);
              return DateFormat.MMMd()
                  .format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
            },
            interval: (maxX - minX) / interval),

        /// Y axis
        leftTitles: SideTitles(
          showTitles: false,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            return value.toString();
          },
          // margin: 8,
          // reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: minX,
      maxX: maxX,
      maxY: 200,
      minY: 0,
      lineBarsData: data,
    );
  }

  LineChartBarData makeLinesBarData({List<FlSpot> spots, Color color}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: barWidth,
      isStrokeCapRound: true,
      colors: [color],
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserWellbeingDB>(context).getOverallTrendsForPastFourMonth();

    /// Future Builder
    final lineChartTrends = FutureBuilder(
        future: _getFutureTrends(),
        builder: (context, snapshot) {
          print("Trends snapshot.connectionState: ${snapshot.connectionState}");

          /// Process indicator for data to be loaded up
          while (snapshot.connectionState == ConnectionState.waiting) {
            print("Snapshot is waiting....");
            return loadingIndicator();
          }

          if (snapshot.hasData) {
            print("Snapshot has data!");
            if (snapshot.data.isNotEmpty) {
              print("Snapshot check: isNotEmpty == true");
              final dataFromDB = snapshot.data;
              double minX;
              if (dataFromDB.length == 1) {
                minX = DateTime.now()
                    .subtract(Duration(days: 7))
                    .millisecondsSinceEpoch
                    .toDouble();
              } else {
                minX = DateTime.parse(dataFromDB[0].date)
                    .millisecondsSinceEpoch
                    .toDouble();
              }
              final maxX = DateTime.parse(dataFromDB.last.date)
                  .millisecondsSinceEpoch
                  .toDouble();

              List<FlSpot> lineChartBarDataSteps = [];
              List<FlSpot> lineChartBarDataWellbeingScore = [];
              List<FlSpot> lineChartBarDatasputumColour = [];
              List<FlSpot> lineChartBarDatamrcDyspnoeaScale = [];
              List<FlSpot> lineChartBarDataspeechRate = [];

              dataFromDB.forEach((wellbeingItem) {
                // print(
                //     """${DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble()}   ||
                // ${wellbeingItem.numSteps / 1000}  || ${wellbeingItem.wellbeingScore} """);
                //
                print(
                    "${FlSpot(DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble(), wellbeingItem.numSteps / 1000)}");
                lineChartBarDataSteps.add(
                  FlSpot(
                      DateTime.parse(wellbeingItem.date)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      (wellbeingItem.numSteps / 1000).roundToDouble()),
                );

                print(
                    "${FlSpot(DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble(), wellbeingItem.wellbeingScore)}");
                lineChartBarDataWellbeingScore.add(
                  FlSpot(
                      DateTime.parse(wellbeingItem.date)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      double.parse(
                          wellbeingItem.wellbeingScore.toStringAsFixed(2))),
                );
                lineChartBarDatasputumColour.add(
                  FlSpot(
                      DateTime.parse(wellbeingItem.date)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      double.parse(
                          wellbeingItem.sputumColour.toStringAsFixed(2))),
                );
                lineChartBarDatamrcDyspnoeaScale.add(
                  FlSpot(
                      DateTime.parse(wellbeingItem.date)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      double.parse(
                          wellbeingItem.mrcDyspnoeaScale.toStringAsFixed(2))),
                );
                lineChartBarDataspeechRate.add(
                  FlSpot(
                      DateTime.parse(wellbeingItem.date)
                          .millisecondsSinceEpoch
                          .toDouble(),
                      double.parse(
                          wellbeingItem.speechRate.toStringAsFixed(2))),
                );
              });

              List<LineChartBarData> data = [
                makeLinesBarData(
                  spots: lineChartBarDataSteps,
                  color: Theme.of(context).colorScheme.primaryVariant,
                ),
                makeLinesBarData(
                  spots: lineChartBarDataWellbeingScore,
                  color: Theme.of(context).colorScheme.secondaryVariant,
                ),
                makeLinesBarData(
                  spots: lineChartBarDatasputumColour,
                  color: Theme.of(context).colorScheme.surface,
                ),
                makeLinesBarData(
                  spots: lineChartBarDatamrcDyspnoeaScale,
                  color: Theme.of(context).colorScheme.background,
                ),
                makeLinesBarData(
                  spots: lineChartBarDataspeechRate,
                  color: Theme.of(context).colorScheme.onSecondary,
                )
              ];

              return LineChart(lineChartData(
                  data: data,
                  minX: minX,
                  maxX: maxX,
                  interval: dataFromDB.length));
            }
          }
          return Center(child: Text("No data available"));
        });
    return lineChartTrends;
  }
}
