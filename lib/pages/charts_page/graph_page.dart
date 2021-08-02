import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nudge_me/pages/add_data.dart';
import 'package:nudge_me/pages/wellbeing_page/wellbeing_page.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'bar_graph.dart';
import 'line_graph.dart';

class ChartPage extends StatefulWidget {
  final CardClass card;
  const ChartPage({key, this.card}) : super(key: key);

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  timeFrame _timeFrame = timeFrame.Week;
  dataToExport _dataToExport = dataToExport.Steps;
  int initialIndex = 0;

  /// Data sharing preferences Modal
  Future<Null> _sharingPreferences() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Share Preferences"),
            // content: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 0, 10),
                child: Text(
                  "Select Time Frame",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              for (var value in timeFrame.values)
                ListTile(
                  title: Text(value.toString().split('.').elementAt(1)),
                  leading: Radio(
                      value: value,
                      groupValue: _timeFrame,
                      onChanged: (timeFrame selectedTimeFrame) {
                        _timeFrame = selectedTimeFrame;
                      }),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 0, 10),
                child: Text(
                  "Select Data to Export",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              for (var value in dataToExport.values)
                ListTile(
                  title: Text(value.toString().split('.').elementAt(1)),
                  leading: Radio(
                      value: value,
                      groupValue: _dataToExport,
                      onChanged: (dataToExport selectedDataToExport) {
                        _dataToExport = selectedDataToExport;
                      }),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SimpleDialogOption(
                      onPressed: () {},
                      child: const Text('Cancel'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {},
                      child: const Text('Export'),
                    )
                  ],
                ),
              )
            ],
          );
        })) {
      case timeFrame.Week:
        break;
      case timeFrame.Month:
        break;
      case timeFrame.Year:
        break;
    }
  }

  showEndDate({int cardId, int initialIndex}) {
    if (cardId == 5) {
      return DateFormat.yMMMMd('en_US').format(DateTime.now()
          .subtract(Duration(days: 29 - (DateTime.now().weekday))));
    } else {
      switch ((cardId == 0) ? initialIndex : (initialIndex + 1)) {
        case 0:
          return DateFormat.yMMMd('en_US')
              .format(DateTime.now().subtract(Duration(days: 6)));
        case 1:
          DateTime nextDate;
          if (DateTime.now().weekday == 7) {
            nextDate = DateTime.now();
          } else {
            nextDate = DateTime.now()
                .subtract(Duration(days: DateTime.now().weekday - 1));
          }
          return DateFormat.yMMMMd('en_US')
              .format(nextDate.subtract(Duration(days: 28)));
        case 2:
          return DateFormat.yMMMMd('en_US').format(DateTime.utc(
              DateTime.now().year,
              DateTime.now().month - 11,
              DateTime.now().day));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Share data button
    /// Ref: https://flutter.dev/docs/release/breaking-changes/buttons
    TextButton shareDataButton = TextButton(
      onPressed: () {
        _sharingPreferences();
      },
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Text("Share "),
        Icon(Icons.share),
      ]),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        fixedSize: MaterialStateProperty.all<Size>(Size(
            MediaQuery.of(context).size.width * 0.95,
            MediaQuery.of(context).size.height * 0.05)),
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).colorScheme.secondary),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered))
              return Colors.purple.withOpacity(0.5);
            if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.pressed))
              return Colors.purple.withOpacity(0.5);
            return Colors.lightBlue
                .withOpacity(0.04); // Defer to the widget's default.
          },
        ),
      ),
    );

    /// Toggle Button
    ToggleSwitch timeFrameSelector = ToggleSwitch(
      initialLabelIndex: initialIndex,
      minWidth: MediaQuery.of(context).size.width * 0.95,
      minHeight: MediaQuery.of(context).size.height * 0.04,
      activeBgColors: [
        [Theme.of(context).colorScheme.secondary],
        [Theme.of(context).colorScheme.secondary],
        [Theme.of(context).colorScheme.secondary]
      ],
      inactiveBgColor: Colors.grey[100],
      totalSwitches: (widget.card.cardId == 0) ? 3 : 2,
      labels: (widget.card.cardId == 0)
          ? ['Week', 'Month', 'Year']
          : [
              'Month',
              'Year'
            ], // with just animate set to true, default curve = Curves.easeIn
      radiusStyle: true,
      cornerRadius: 15.0,
      onToggle: (index) {
        setState(() {
          initialIndex = index;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () {
                  Navigator.pop(context,
                      MaterialPageRoute(builder: (context) => WellbeingPage()));
                });
          },
        ),
        title: Text(
          widget.card.titleOfCard,
          style: Theme.of(context).textTheme.subtitle1.merge(
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: (widget.card.cardId == 5)
                      ? SizedBox.shrink()
                      : timeFrameSelector,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.grey[100],
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.card.units,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      (widget.card.cardId == 0 ||
                                              widget.card.cardId == 5)
                                          ? SizedBox.shrink()
                                          : TextButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddData(
                                                            card: widget.card),
                                                  ),
                                                );
                                              },
                                              label: Text("Add Data"),
                                              icon: Icon(Icons.add),
                                            )
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 20),
                                    child: Row(
                                      children: [
                                        Text(
                                            showEndDate(
                                                cardId: widget.card.cardId,
                                                initialIndex: initialIndex),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                        Icon(Icons.arrow_forward),
                                        Text(
                                            DateFormat.yMMMMd('en_US')
                                                .format(DateTime.now()),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: (widget.card.cardId == 5)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: LineChartTrends(
                                                  card: widget.card),
                                            )
                                          : Provider.value(
                                              value: initialIndex,
                                              updateShouldNotify:
                                                  (oldValue, newValue) =>
                                                      newValue != oldValue,
                                              child: BarChartWidget(
                                                  card: widget.card,
                                                  initialIndex: initialIndex))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: shareDataButton,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.grey[100],
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                  (widget.card.cardId != 5) ? "About" : "Key",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                            widget.card.cardDescription
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget key({Color color, String text}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: color,
            ),
            height: 40,
            width: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}

enum timeFrame {
  Week,
  Month,
  Year,
}

enum dataToExport { Steps, Wellbeing, Breathlessness, SpeechRate, SputumColor }
