import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:intl/intl.dart';
import 'package:nudge_me/shared/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_preprocessing/ml_preprocessing.dart';
import 'package:moving_average/moving_average.dart';

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
        .getOverallTrendsForPastNWeeks(5);
  }

  LineChartData lineChartData({data, minX, maxX, interval}) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          // rotateAngle: 40,
        ),
        touchCallback: (LineTouchResponse touchResponse) {
          // print("touchResponse: ${touchResponse.lineBarSpots}");
        },
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
            getTextStyles: (value) => TextStyle(
                  color: Color.fromRGBO(1, 1, 1, 1),
                  fontSize: 12,
                ),
            margin: 20,
            getTitles: (value) {
              // print(value);
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
          getTextStyles: (value) => const TextStyle(
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
    // Provider.of<UserWellbeingDB>(context).getOverallTrendsForPastFourMonth();
    Provider.of<UserWellbeingDB>(context, listen: true)
        .dataPastWeekToPublish()
        .then((value) {
      print(
          "${value[0].numSteps} || ${value[0].wellbeingScore} || ${value[0].sputumColour}");
    });

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
              if (snapshot.data.length < 3) {
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
                print("Snapshot check: isNotEmpty == true");
                final dataFromDB = snapshot.data;
                double minX;
                if (dataFromDB.length == 1) {
                  minX = DateTime.now()
                      .subtract(Duration(days: 7))
                      .millisecondsSinceEpoch
                      .toDouble();
                } else {
                  minX = DateTime.parse(dataFromDB.first.date)
                      .millisecondsSinceEpoch
                      .toDouble();
                }
                double maxX = DateTime.parse(dataFromDB.last.date)
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
                dataFromDB.forEach((wellbeingItem) {
                  dataSteps.add(wellbeingItem.numSteps.toDouble());
                  dataWellbeingScore
                      .add(wellbeingItem.wellbeingScore.toDouble());
                  datasputumColour.add(wellbeingItem.sputumColour.toDouble());
                  datamrcDyspnoeaScale
                      .add(wellbeingItem.mrcDyspnoeaScale.toDouble());
                  // dataspeechRate.add(wellbeingItem.speechRate.toDouble());
                });

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
                final mADataWellbeingScore =
                    twoWeekMovingAverage(dataWellbeingScore);
                final mAdatasputumColour =
                    twoWeekMovingAverage(datasputumColour);
                final mAdatamrcDyspnoeaScale =
                    twoWeekMovingAverage(datamrcDyspnoeaScale);
                // final mAdataspeechRate = twoWeekMovingAverage(dataspeechRate);

                /// No Moving Average
                // print("mADataSteps: ${mADataSteps.reduce(min)}");
                // minMA(listOfValues) {
                //   return listOfValues.cast<double>().reduce(min).toDouble();
                // }
                //
                // maxMA(listOfValues) {
                //   return listOfValues.cast<num>().reduce(max).toDouble();
                // }
                //
                // // /// Min values for
                // // print("mADataSteps: $mADataSteps");
                // // final minMASteps = minMA(mADataSteps);
                // // final minMAWellbeingScore = minMA(mADataWellbeingScore);
                // // final minMASputumColour = minMA(mAdatasputumColour);
                // // final minMAmrcDyspnoeaScale = minMA(mAdatamrcDyspnoeaScale);
                // // final minMASpeechRate = minMA(mAdataspeechRate);

                /// Always need this
                List<FlSpot> lineChartBarDataSteps = [];
                List<FlSpot> lineChartBarDataWellbeingScore = [];
                List<FlSpot> lineChartBarDatasputumColour = [];
                List<FlSpot> lineChartBarDatamrcDyspnoeaScale = [];
                List<FlSpot> lineChartBarDataspeechRate = [];

                /// No Moving Average
                // List listOfMin = [
                //   dataFromDB.first.numSteps,
                //   dataFromDB.first.wellbeingScore,
                //   dataFromDB.first.sputumColour,
                //   dataFromDB.first.mrcDyspnoeaScale,
                //   dataFromDB.first.speechRate
                // ];
                // List listOfMax = [
                //   dataFromDB.first.numSteps,
                //   dataFromDB.first.wellbeingScore,
                //   dataFromDB.first.sputumColour,
                //   dataFromDB.first.mrcDyspnoeaScale,
                //   dataFromDB.first.speechRate
                // ];
                // dataFromDB.forEach((wellbeingItem) {
                //   if (wellbeingItem.numSteps < listOfMin[0]) {
                //     listOfMin[0] = wellbeingItem.numSteps;
                //   } else if (wellbeingItem.numSteps > listOfMax[0]) {
                //     listOfMax[0] = wellbeingItem.numSteps;
                //   }
                //
                //   if (wellbeingItem.wellbeingScore < listOfMin[1]) {
                //     listOfMin[1] = wellbeingItem.wellbeingScore;
                //   } else if (wellbeingItem.wellbeingScore > listOfMax[1]) {
                //     listOfMax[1] = wellbeingItem.wellbeingScore;
                //   }
                //
                //   if (wellbeingItem.sputumColour < listOfMin[2]) {
                //     listOfMin[2] = wellbeingItem.sputumColour;
                //   } else if (wellbeingItem.sputumColour > listOfMax[2]) {
                //     listOfMax[2] = wellbeingItem.sputumColour;
                //   }
                //
                //   if (wellbeingItem.mrcDyspnoeaScale < listOfMin[3]) {
                //     listOfMin[3] = wellbeingItem.mrcDyspnoeaScale;
                //   } else if (wellbeingItem.mrcDyspnoeaScale > listOfMax[3]) {
                //     listOfMax[3] = wellbeingItem.mrcDyspnoeaScale;
                //   }
                //
                //   if (wellbeingItem.speechRate < listOfMin[4]) {
                //     listOfMin[4] = wellbeingItem.speechRate;
                //   } else if (wellbeingItem.speechRate > listOfMax[4]) {
                //     listOfMax[4] = wellbeingItem.speechRate;
                //   }
                // });

                /// Additional Checks for Without Moving Average
                // double xmin = listOfMin.cast<num>().reduce(min).toDouble();
                // double xmax = listOfMax.cast<num>().reduce(max).toDouble();
                // print("listOfMin: $listOfMin");
                // print("listOfMin: ${listOfMin.cast<num>().reduce(min)}");
                // print("listOfMax: $listOfMax");
                // print("listOfMax: ${listOfMax.cast<num>().reduce(max)}");

                /// Normalisation: x = (x - xmin)/(xmax - xmin)
                /// With Moving Average
                for (var i = 0; i <= dataFromDB.length - 1; i++) {
                  /// Number of steps
                  lineChartBarDataSteps.add(
                    FlSpot(
                        DateTime.parse(dataFromDB[i].date)
                            .millisecondsSinceEpoch
                            .toDouble(),
                        (mADataSteps[i] == null)
                            ? 0
                            : ((mADataSteps[i] - mADataSteps.reduce(min)) /
                                (mADataSteps.reduce(max) -
                                    mADataSteps.reduce(min)))),
                  );

                  /// Wellbeing Score
                  lineChartBarDataWellbeingScore.add(
                    FlSpot(
                        DateTime.parse(dataFromDB[i].date)
                            .millisecondsSinceEpoch
                            .toDouble(),
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
                        DateTime.parse(dataFromDB[i].date)
                            .millisecondsSinceEpoch
                            .toDouble(),
                        (mAdatasputumColour[i] == null)
                            ? 0
                            : ((mAdatasputumColour[i] -
                                    mAdatasputumColour.reduce(min)) /
                                (mAdatasputumColour.reduce(max) -
                                    mAdatasputumColour.reduce(min)))),
                  );

                  /// MRC Dyspnoea Scale
                  lineChartBarDatamrcDyspnoeaScale.add(
                    FlSpot(
                        DateTime.parse(dataFromDB[i].date)
                            .millisecondsSinceEpoch
                            .toDouble(),
                        (mAdatamrcDyspnoeaScale[i] == null)
                            ? 0
                            : ((mAdatamrcDyspnoeaScale[i] -
                                    mAdatamrcDyspnoeaScale.reduce(min)) /
                                (mAdatamrcDyspnoeaScale.reduce(max) -
                                    mAdatamrcDyspnoeaScale.reduce(min)))),
                  );

                  /// Speech Rate
                  // lineChartBarDataspeechRate.add(
                  //   FlSpot(
                  //       DateTime.parse(dataFromDB[i].date)
                  //           .millisecondsSinceEpoch
                  //           .toDouble(),
                  //       (mAdataspeechRate[i] == null)
                  //           ? 0
                  //           : ((mAdataspeechRate[i] -
                  //                   mAdataspeechRate.reduce(min)) /
                  //               (mAdataspeechRate.reduce(max) -
                  //                   mAdataspeechRate.reduce(min)))),
                  // );
                }

                /// No Moving Average
                // dataFromDB.forEach((wellbeingItem) {
                //   // print(
                //   //     """${DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble()}   ||
                //   // ${wellbeingItem.numSteps / 1000}  || ${wellbeingItem.wellbeingScore} """);
                //   //
                //
                //   // print(
                //   //     "${FlSpot(DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble(), (wellbeingItem.numSteps == null) ? 0 : wellbeingItem.numSteps / 1000)}");
                //   lineChartBarDataSteps.add(
                //     FlSpot(
                //         DateTime.parse(wellbeingItem.date)
                //             .millisecondsSinceEpoch
                //             .toDouble(),
                //         (wellbeingItem.numSteps == null)
                //             ? 0
                //             : ((wellbeingItem.numSteps - listOfMin[0]) /
                //                 (listOfMax[0] - listOfMin[0]))),
                //   );
                //
                //   // print(
                //   //     "${FlSpot(DateTime.parse(wellbeingItem.date).millisecondsSinceEpoch.toDouble(), (wellbeingItem.wellbeingScore == null) ? 0 : wellbeingItem.wellbeingScore)}");
                //   lineChartBarDataWellbeingScore.add(
                //     FlSpot(
                //         DateTime.parse(wellbeingItem.date)
                //             .millisecondsSinceEpoch
                //             .toDouble(),
                //         (wellbeingItem.wellbeingScore == null)
                //             ? 0
                //             : ((wellbeingItem.wellbeingScore - listOfMin[1]) /
                //                 (listOfMax[1] - listOfMin[1]))),
                //   );
                //   lineChartBarDatasputumColour.add(
                //     FlSpot(
                //         DateTime.parse(wellbeingItem.date)
                //             .millisecondsSinceEpoch
                //             .toDouble(),
                //         (wellbeingItem.sputumColour == null)
                //             ? 0
                //             : ((wellbeingItem.sputumColour - listOfMin[2]) /
                //                 (listOfMax[2] - listOfMin[2]))),
                //   );
                //   lineChartBarDatamrcDyspnoeaScale.add(
                //     FlSpot(
                //         DateTime.parse(wellbeingItem.date)
                //             .millisecondsSinceEpoch
                //             .toDouble(),
                //         (wellbeingItem.mrcDyspnoeaScale == null)
                //             ? 0
                //             : ((wellbeingItem.mrcDyspnoeaScale - listOfMin[3]) /
                //                 (listOfMax[3] - listOfMin[3]))),
                //   );
                //   lineChartBarDataspeechRate.add(
                //     FlSpot(
                //         DateTime.parse(wellbeingItem.date)
                //             .millisecondsSinceEpoch
                //             .toDouble(),
                //         (wellbeingItem.speechRate == null)
                //             ? 0
                //             : ((wellbeingItem.speechRate - listOfMin[4]) /
                //                 (listOfMax[4] - listOfMin[4]))),
                //   );
                // });
                // print(lineChartBarDataSteps);

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
                print(DateTime.parse(dataFromDB.last.date));
                return LineChart(lineChartData(
                    data: data,
                    minX: minX,
                    maxX: maxX,
                    interval: dataFromDB.length + 1));
              }
            }
          }
          return Center(child: Text("No data available"));
        });

    return lineChartTrends;
  }
}
