import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nudge_me/pages/charts_page/bar_graph_settings.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class SharedBarChart extends StatefulWidget {
  final int cardId;
  final Map<String, double> hashMapForBarChart;
  final CardClass card;
  const SharedBarChart(
      {Key key, this.cardId, this.hashMapForBarChart, this.card})
      : super(key: key);

  @override
  _SharedBarChartState createState() => _SharedBarChartState();
}

class _SharedBarChartState extends State<SharedBarChart> {
  final Color barBackgroundColor = Colors.white;
  int barchartIndex = -1;
  List<BarChartGroupData> barChartData = [];
  List<double> findMax = [];
  int touchedIndex = -1;

  /// Data class for the barchart
  BarChartGroupData makeGroupData(
    int x,
    double y,
    double maxY, {
    bool isTouched = false,
    Color barColor = Colors.lightBlue,
    double width = 16,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          colors: isTouched ? [Colors.yellow] : [widget.card.color],
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: maxYaxis(
                cardId: widget.cardId,
                initialIndex: (widget.cardId == 0) ? 1 : 0,
                dynamicMaxValue: maxY),
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  BarChartData mainBarData({List<BarChartGroupData> data, double maxY = 0}) {
    return BarChartData(
      // TODO: Create a Switch-Case statement to get data for week/month/year
      maxY: maxYaxis(
          cardId: widget.cardId,
          initialIndex: (widget.cardId == 0) ? 1 : 0,
          dynamicMaxValue: maxY),
      minY: 0,

      /// Passing the actual data into the BarChart
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
            margin: 16,
            getTitles: (double value) {
              var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return DateFormat.MMMd()
                  .format(date.subtract(Duration(days: (date.weekday - 1))));
            }),

        /// Y-axis
        rightTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
          margin: 6,
          interval: stepSize(
              cardId: widget.card.cardId,
              initialIndex: (widget.cardId == 0) ? 1 : 0,
              dynamicMaxValue: maxY),
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: data,
    );
  }

  @override
  Widget build(BuildContext context) {
    ///Finding max
    widget.hashMapForBarChart.forEach((key, value) {
      findMax.add(value);
    });

    double maxYaxis = findMax.reduce(max).toDouble();

    /// Generating barChartData
    widget.hashMapForBarChart.forEach((key, value) {
      barChartData.add(makeGroupData(
          DateTime.parse(key).millisecondsSinceEpoch, value, maxYaxis,
          isTouched: (barchartIndex += 1) == touchedIndex));
    });

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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.card.units,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BarChart(
                      mainBarData(data: barChartData, maxY: maxYaxis),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
