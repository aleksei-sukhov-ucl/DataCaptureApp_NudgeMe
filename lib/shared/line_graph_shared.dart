import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:moving_average/moving_average.dart';

class LineChartTrendsShared extends StatefulWidget {
  final Map<String, List<double>> hashMapForLineChart;

  const LineChartTrendsShared({Key key, this.hashMapForLineChart})
      : super(key: key);
  @override
  _LineChartTrendsSharedState createState() => _LineChartTrendsSharedState();
}

class _LineChartTrendsSharedState extends State<LineChartTrendsShared> {
  final double barWidth = 4;

  LineChartData lineChartData({data, minX, maxX, interval}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          // rotateAngle: 40,
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: false,
      ),
      gridData: FlGridData(
        show: false,
      ),

      /// X axis
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
            rotateAngle: 45,
            showTitles: true,
            reservedSize: MediaQuery.of(context).size.width * 0.07,
            getTextStyles: (context, value) => TextStyle(
                  color: Color.fromRGBO(1, 1, 1, 1),
                  fontSize: 12,
                ),
            margin: 20,
            getTitles: (value) {
              return DateFormat.MMMd()
                  .format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
            },
            interval: (maxX - minX) / interval),

        /// Y axis
        leftTitles: SideTitles(
          showTitles: true,
          margin: 20,
          reservedSize: MediaQuery.of(context).size.width * 0.055,
          interval: 0.25,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff75729e),
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
      maxY: 1,
      minY: 0,
      lineBarsData: data,
    );
  }

  LineChartBarData makeLinesBarData({List<FlSpot> spots, Color color}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
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
    lineChartTrends() {
      if (widget.hashMapForLineChart.length < 3) {
        return Center(
          child: Container(
            width: 250,
            child: Text(
              "Not Enough data yet, at least 3 weeks of data is required. \n\nPlease come back later!",
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        double minX;
        if (widget.hashMapForLineChart.length == 1) {
          minX = DateTime.now()
              .subtract(Duration(days: 7))
              .millisecondsSinceEpoch
              .toDouble();
        } else {
          minX = DateTime.parse(widget.hashMapForLineChart.keys.elementAt(0))
              .millisecondsSinceEpoch
              .toDouble();
        }
        double maxX = DateTime.parse(widget.hashMapForLineChart.keys
                .elementAt(widget.hashMapForLineChart.length - 1))
            // .subtract(Duration(days: -7))
            .millisecondsSinceEpoch
            .toDouble();

        /// With Moving Average
        ///Lists of data grouped by Wellbeing Class instance
        List<double> dataSteps = [];
        List<double> dataWellbeingScore = [];
        List<double> datasputumColour = [];
        List<double> datamrcDyspnoeaScale = [];
        // List<double> dataspeechRate = [];

        /// With Moving Average
        widget.hashMapForLineChart.forEach((key, value) {
          List<double> dataForOneDay = widget.hashMapForLineChart[key].toList();
          dataSteps.add(dataForOneDay[0]);
          dataWellbeingScore.add(dataForOneDay[1]);
          datasputumColour.add(dataForOneDay[2]);
          datamrcDyspnoeaScale.add(dataForOneDay[3]);
        });

        print("dataSteps: $dataSteps");
        print("dataWellbeingScore: $dataWellbeingScore");

        /// Function to workout 2 Week moving average
        final twoWeekMovingAverage = MovingAverage<double>(
          averageType: AverageType.simple,
          windowSize: 2,
          partialStart: true,
          getValue: (num n) => n,
          add: (List<double> data, num value) => value,
        );

        ///Lists of data with 2 week moving averages
        final mADataSteps = twoWeekMovingAverage(dataSteps);
        final mADataWellbeingScore = twoWeekMovingAverage(dataWellbeingScore);
        final mADatasputumColour = twoWeekMovingAverage(datasputumColour);
        final mADatamrcDyspnoeaScale =
            twoWeekMovingAverage(datamrcDyspnoeaScale);

        /// Always need this
        List<FlSpot> lineChartBarDataSteps = [];
        List<FlSpot> lineChartBarDataWellbeingScore = [];
        List<FlSpot> lineChartBarDatasputumColour = [];
        List<FlSpot> lineChartBarDatamrcDyspnoeaScale = [];
        List<FlSpot> lineChartBarDataspeechRate = [];

        for (var i = 0; i <= widget.hashMapForLineChart.length - 1; i++) {
          String date = widget.hashMapForLineChart.keys.elementAt(i);
          print("date:$date");

          /// Number of steps
          lineChartBarDataSteps.add(
            FlSpot(
                DateTime.parse(date).millisecondsSinceEpoch.toDouble(),
                (mADataSteps[i] == null)
                    ? 0
                    : ((mADataSteps[i] - mADataSteps.reduce(min)) /
                        (mADataSteps.reduce(max) - mADataSteps.reduce(min)))),
          );

          /// Wellbeing Score
          lineChartBarDataWellbeingScore.add(
            FlSpot(
                DateTime.parse(date).millisecondsSinceEpoch.toDouble(),
                (mADataWellbeingScore[i] == null)
                    ? 0
                    : ((mADataWellbeingScore[i] -
                            mADataWellbeingScore.reduce(min)) /
                        (mADataWellbeingScore.reduce(max) -
                            mADataWellbeingScore.reduce(min)))),
          );

          /// Sputum Color
          lineChartBarDatasputumColour.add(
            FlSpot(
                DateTime.parse(date).millisecondsSinceEpoch.toDouble(),
                (mADatasputumColour[i] == null)
                    ? 0
                    : ((mADatasputumColour[i] -
                            mADatasputumColour.reduce(min)) /
                        (mADatasputumColour.reduce(max) -
                            mADatasputumColour.reduce(min)))),
          );

          /// MRC Dyspnoea Scale
          lineChartBarDatamrcDyspnoeaScale.add(
            FlSpot(
                DateTime.parse(date).millisecondsSinceEpoch.toDouble(),
                (mADatamrcDyspnoeaScale[i] == null)
                    ? 0
                    : ((mADatamrcDyspnoeaScale[i] -
                            mADatamrcDyspnoeaScale.reduce(min)) /
                        (mADatamrcDyspnoeaScale.reduce(max) -
                            mADatamrcDyspnoeaScale.reduce(min)))),
          );
        }
        List<LineChartBarData> data = [
          makeLinesBarData(
            spots: lineChartBarDataSteps,
            color: Color.fromRGBO(123, 230, 236, 1),
          ),
          makeLinesBarData(
            spots: lineChartBarDataWellbeingScore,
            color: Colors.deepPurple,
          ),
          makeLinesBarData(
            spots: lineChartBarDatasputumColour,
            color: Color.fromRGBO(251, 222, 147, 1),
          ),
          makeLinesBarData(
            spots: lineChartBarDatamrcDyspnoeaScale,
            color: Color.fromRGBO(138, 127, 245, 1),
          ),
          makeLinesBarData(
            spots: lineChartBarDataspeechRate,
            color: Color.fromRGBO(241, 139, 128, 1.0),
          )
        ];

        return LineChart(lineChartData(
            data: data,
            minX: minX,
            maxX: maxX,
            interval: widget.hashMapForLineChart.length + 1));
      }
    }

    return Container(
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
                      child: lineChartTrends(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
