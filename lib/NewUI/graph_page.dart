import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:nudge_me/pages/WellbeingPage/cards.dart';

import 'chart.dart';

class BarChartPage extends StatefulWidget {
  final CardClass card;
  const BarChartPage({key, this.card}) : super(key: key);

  @override
  State<BarChartPage> createState() => _BarChartPageState();
}

class _BarChartPageState extends State<BarChartPage> {
  timeFrame _timeFrame = timeFrame.Week;
  dataToExport _dataToExport = dataToExport.Steps;

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

            // ),
            /**/ // actions: [
            //   TextButton(
            //     onPressed: () {},
            //     child: Text('Cancel'),
            //   ),
            //   TextButton(
            //     onPressed: () {},
            //     child: Text('Export'),
            //   ),
            // ],
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
        fixedSize: MaterialStateProperty.all<Size>(Size(380, 40)),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
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

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SafeArea(
              child: Align(
                alignment: Alignment(-0.9, 1),
                child: Text(
                  widget.card.titleOfCard,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            BarChartWidget(card: widget.card),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: shareDataButton,
            )
          ],
        ),
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
