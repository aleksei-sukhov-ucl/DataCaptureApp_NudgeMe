import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:nudge_me/pages/WellbeingPage/cards.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'chart_settings.dart';

/// Ref: https://github.com/imaNNeoFighT/fl_chart/blob/master/example/lib/bar_chart/samples/bar_chart_sample1.dart

class BarChartWidget extends StatefulWidget {
  final CardClass card;
  // final String titleOfCard;
  // final String units;
  // final CardClass cardInfo;

  const BarChartWidget({
    key,
    this.card,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final Color barBackgroundColor = Colors.white;
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  int initialIndex = 0;

  /// Building a card with a graph
  @override
  Widget build(BuildContext context) {
    /// Toggle Button
    ToggleSwitch timeFrameSelector = ToggleSwitch(
      initialLabelIndex: initialIndex,
      minWidth: 400,
      activeBgColors: [
        [Colors.lightBlue],
        [Colors.lightBlue],
        [Colors.lightBlue]
      ],
      inactiveBgColor: Colors.grey[100],
      totalSwitches: 3,
      labels: [
        'Week',
        'Month',
        'Year'
      ], // with just animate set to true, default curve = Curves.easeIn
      radiusStyle: true,
      cornerRadius: 15.0,
      onToggle: (index) {
        print('switched to: $index');
        setState(() {
          initialIndex = index;
        });
      },
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: timeFrameSelector,
        ),
        Container(
          height: 400,
          width: 380,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.grey[100],
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Text(
                          widget.card.units,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: BarChart(
                          mainBarData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Data generation for Barchart
  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.lightBlue,
    double width = 16,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y : y,
          colors: isTouched ? [Colors.yellow] : [widget.card.color],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: maxYaxis(widget.card.cardId),
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  /// List of data generated for a week timeframe
  List<BarChartGroupData> weeklyShowingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 6, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 6, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 6, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  /// List of data generated for a month timeframe
  List<BarChartGroupData> monthlyShowingGroups() => List.generate(5, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 6, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 6, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  /// List of data generated for a year timeframe
  List<BarChartGroupData> yearlyShowingGroups() => List.generate(12, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 6, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 6, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 6, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6, isTouched: i == touchedIndex);
          case 7:
            return makeGroupData(7, 5, isTouched: i == touchedIndex);
          case 8:
            return makeGroupData(8, 6, isTouched: i == touchedIndex);
          case 9:
            return makeGroupData(9, 5, isTouched: i == touchedIndex);
          case 10:
            return makeGroupData(10, 6, isTouched: i == touchedIndex);
          case 11:
            return makeGroupData(11, 6, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  /// Passing the data into the Barchart + allow to see the data on touch
  BarChartData mainBarData() {
    return BarChartData(
      // TODO: Create a Switch-Case statement to get data for week/month/year
      maxY: maxYaxis(widget.card.cardId),
      minY: 0,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDayWeekMonth;
              switch (initialIndex) {
                case 0:
                  weekDayWeekMonth = weekDayDescription(group);
                  break;
                case 1:
                  weekDayWeekMonth = monthWeekDescription(group);
                  break;
                case 2:
                  weekDayWeekMonth = yearMonthDescription(group);
                  break;
                default:
                  throw Error();
              }

              /// Popup with the information
              return BarTooltipItem(
                weekDayWeekMonth + '\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  // TODO: Create a Switch-Case statement to get data for week/month/year
                  TextSpan(
                    text: (rod.y).toString() + popupUnits(widget.card.cardId),
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),

        /// Making on tap dynamic so it disappears after on tap even
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! PointerUpEvent &&
                barTouchResponse.touchInput is! PointerExitEvent) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),

      /// Passing the actual data into the BarChart
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
            margin: 16,
            // TODO: Create a Switch-Case statement to get data for week/month/year
            getTitles: (double value) {
              switch (initialIndex) {
                case 0:
                  print("getTitles case 0");
                  return weekXAxisUnits(value);
                case 1:
                  print("getTitles case 1");
                  return monthXAxisUnits(value);
                case 2:
                  print("getTitles case 2");
                  return yearXAxisUnits(value);
                default:
                  return " ";
              }
            }),
        rightTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
          margin: 10,
          interval: stepSize(widget.card.cardId),
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      // TODO: Create a Switch-Case statement to get data for week/month/year
      barGroups: timeFrameData(initialIndex),
    );
  }

  /// Selecting Correct dataset for week/month/year
  List<BarChartGroupData> timeFrameData(int initialIndex) {
    switch (initialIndex) {
      case 0:
        return weeklyShowingGroups();
      case 1:
        return monthlyShowingGroups();
      case 2:
        return yearlyShowingGroups();
      default:
        return weeklyShowingGroups();
    }
  }

  weekXAxisUnits(double value) {
    switch (value.toInt()) {
      case 0:
        return 'M';
      case 1:
        return 'T';
      case 2:
        return 'W';
      case 3:
        return 'T';
      case 4:
        return 'F';
      case 5:
        return 'S';
      case 6:
        return 'S';
      default:
        return '';
    }
  }

  monthXAxisUnits(double value) {
    switch (value.toInt()) {
      case 0:
        return '28';
      case 1:
        return '5';
      case 2:
        return '12';
      case 3:
        return '19';
      case 4:
        return '26';
      // case 5:
      //   return '2';
      // case 6:
      //   return 'J';
      // case 7:
      //   return 'A';
      // case 8:
      //   return 'S';
      // case 9:
      //   return '0';
      // case 10:
      //   return 'N';
      // case 11:
      //   return 'D';
      default:
        return '';
    }
  }

  yearXAxisUnits(double value) {
    switch (value.toInt()) {
      case 0:
        return 'J';
      case 1:
        return 'F';
      case 2:
        return 'M';
      case 3:
        return 'A';
      case 4:
        return 'M';
      case 5:
        return 'J';
      case 6:
        return 'J';
      case 7:
        return 'A';
      case 8:
        return 'S';
      case 9:
        return '0';
      case 10:
        return 'N';
      case 11:
        return 'D';
      default:
        return '';
    }
  }

  weekDayDescription(group) {
    /// Matching week day index with corresponding name
    switch (group.x.toInt()) {
      case 0:
        return 'Monday';
      case 1:
        return 'Tuesday';
      case 2:
        return 'Wednesday';
      case 3:
        return 'Thursday';
      case 4:
        return 'Friday';
      case 5:
        return 'Saturday';
      case 6:
        return 'Sunday';
      default:
        throw Error();
    }
  }

  monthWeekDescription(group) {
    switch (group.x.toInt()) {
      case 0:
        return '28';
      case 1:
        return '5';
      case 2:
        return '12';
      case 3:
        return '19';
      case 4:
        return '26';
      default:
        throw Error();
    }
  }

  yearMonthDescription(group) {
    switch (group.x.toInt()) {
      case 0:
        return 'January';
      case 1:
        return 'February';
      case 2:
        return 'March';
      case 3:
        return 'April';
      case 4:
        return 'May';
      case 5:
        return 'June';
      case 6:
        return 'July';
      case 7:
        return 'August';
      case 8:
        return 'September';
      case 9:
        return 'October';
      case 10:
        return 'November';
      case 11:
        return 'December';
      default:
        throw Error();
    }
  }

  popupUnits(initialIndex) {
    switch (initialIndex) {
      case 0:
        return "K";
      default:
        return "";
    }
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
  }
}
