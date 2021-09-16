import 'package:flutter/material.dart';
import 'package:nudge_me/shared/share_export_page.dart';

Future<void> showDataSharingDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) {
        timeFrame _timeFrame = timeFrame.Month;

        bool _exportSteps = false;
        bool _exportWellbeing = false;
        bool _exportBreathlessness = false;
        bool _exportSputumColor = false;
        bool _exportOverallTrends = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Share Preferences",
              style: Theme.of(context).textTheme.headline2,
            ),

            /// Timeframe selection
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Select Time Frame",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ListTile(
                        key: Key("Select Month"),
                        visualDensity:
                            VisualDensity(horizontal: 4, vertical: -4),
                        title: Text('Month', style: TextStyle(fontSize: 16)),
                        leading: Radio<timeFrame>(
                          value: timeFrame.Month,
                          groupValue: _timeFrame,
                          onChanged: (timeFrame value) {
                            setState(() {
                              _timeFrame = value;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        key: Key("Select Year"),
                        visualDensity:
                            VisualDensity(horizontal: 4, vertical: -4),
                        title:
                            const Text('Year', style: TextStyle(fontSize: 16)),
                        leading: Radio<timeFrame>(
                          value: timeFrame.Year,
                          groupValue: _timeFrame,
                          onChanged: (timeFrame value) {
                            setState(() {
                              _timeFrame = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  /// Selection of what data to export
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Select Data to Export",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CheckboxListTile(
                        title:
                            const Text('Steps', style: TextStyle(fontSize: 16)),
                        value: _exportSteps,
                        onChanged: (bool value) {
                          setState(() {
                            _exportSteps = !_exportSteps;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Wellbeing Score',
                            style: TextStyle(fontSize: 16)),
                        value: _exportWellbeing,
                        onChanged: (bool value) {
                          setState(() {
                            _exportWellbeing = !_exportWellbeing;
                          });
                        },
                      ),
                      CheckboxListTile(
                        key: Key("Select Sputum Color"),
                        title: const Text('Sputum Color',
                            style: TextStyle(fontSize: 16)),
                        value: _exportSputumColor,
                        onChanged: (bool value) {
                          setState(() {
                            _exportSputumColor = !_exportSputumColor;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('MRC Dyspnoea Scale Score',
                            style: TextStyle(fontSize: 16)),
                        value: _exportBreathlessness,
                        onChanged: (bool value) {
                          setState(() {
                            _exportBreathlessness = !_exportBreathlessness;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Overall Trends (Past 5 weeks)',
                            style: TextStyle(fontSize: 16)),
                        value: _exportOverallTrends,
                        onChanged: (bool value) {
                          setState(() {
                            _exportOverallTrends = !_exportOverallTrends;
                          });
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SimpleDialogOption(
                onPressed: () async {
                  if ((_exportSteps ||
                      _exportWellbeing ||
                      _exportBreathlessness ||
                      _exportSputumColor ||
                      _exportOverallTrends)) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PDFExportPage(
                          timeFrame: _timeFrame.index,
                          exportSteps: _exportSteps,
                          exportWellbeing: _exportWellbeing,
                          exportSputumColor: _exportSputumColor,
                          exportBreathlessness: _exportBreathlessness,
                          exportOverallTrends: _exportOverallTrends,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Export'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"))
            ],
          );
        });
      });
}

enum timeFrame {
  Month,
  Year,
}
