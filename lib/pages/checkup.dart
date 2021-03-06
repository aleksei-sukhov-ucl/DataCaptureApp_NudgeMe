import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/notification.dart';
import 'dart:async';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/shared/audio_recording.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock/clock.dart';

/// Weekly Checkup notification opens this page.
/// Asks user how they are feeling and adds this score and their steps to their graph.
/// NOTE: Wellbeing Check is sometimes referred to as 'Checkup' in this code, as it was called this previously.
class WellbeingCheck extends StatelessWidget {
  final Stream<int> stepValueStream;

  const WellbeingCheck(this.stepValueStream);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Wellbeing Check",
                      style: Theme.of(context).textTheme.headline1),
                  SizedBox(height: 30),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: WellbeingCheckWidgets(stepValueStream)),
                ]),
          ),
        )),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }
}

/// Widgets inside Wellbeing Check page
class WellbeingCheckWidgets extends StatefulWidget {
  final Stream<int> stepValueStream;
  const WellbeingCheckWidgets(this.stepValueStream);

  @override
  _WellbeingCheckWidgetsState createState() => _WellbeingCheckWidgetsState();
}

class _WellbeingCheckWidgetsState extends State<WellbeingCheckWidgets> {
  /// Sets original slider value to 0.
  double _currentSliderValueWellbeing = 0;
  double _currentSliderValueSputumColor = 0;
  double _currentSliderValueMRCDyspnoeaScale = 0;
  int _currentValueSpeechRateTest = 0;
  double _currentValueTestDuration = 30;
  double _currentValueSpeechRate = 0;
  String _currentValueAudioURL;

  /// Initialising Audio Recorder
  @override
  void initState() {
    super.initState();
    // recorder.init();
  }

  callback(String audioFileLocationURL, int currentValueSpeechRateTest,
      double currentValueTestDuration) {
    setState(() {
      _currentValueAudioURL = audioFileLocationURL;
      _currentValueSpeechRateTest = currentValueSpeechRateTest;
      _currentValueTestDuration = currentValueTestDuration;
    });
  }

  final List<String> descriptionsMRCDyspnoeaScale = [
    "Not troubled by breathless except on strenuous exercise",
    "Short of breath when hurrying on a level or when walking up a slight hill",
    "	Walks slower than most people on the level, stops after a mile or so, or stops after 15 minutes walking at own pace",
    "Stops for breath after walking 100 yards, or after a few minutes on level ground",
    "Too breathless to leave the house, or breathless when dressing/undressing  "
  ];

  double sizeBoxHeight = 20;

  /// Widget records the last weeks & current step total. The difference is
  /// the actual step count for the week.
  final Future<int> _lastTotalStepsFuture = SharedPreferences.getInstance()
      .then((prefs) => prefs.getInt(PREV_STEP_COUNT_KEY));

  /// Returns [String] userPostcode stored in shared prefs database
  Future<String> _getPostcode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userPostcode = prefs.getString('postcode');
    return userPostcode;
  }

  /// Returns [String] userSupportCode stored in shared prefs database
  Future<String> _getSupportCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userSupportCode = prefs.getString('support_code');
    return userSupportCode;
  }

  /// Returns `true` if given [List] is monotonically decreasing.
  bool _isDecreasing(List<dynamic> items) {
    for (int i = 0; i < items.length - 1; ++i) {
      if (items[i] <= items[i + 1]) {
        return false;
      }
    }
    return true;
  }

  /// Nudges user if score drops n times in the last n+1 weeks.
  /// For example, if n == 2 and we have these 3 weeks/scores 8 7 6, the user
  /// will be nudged.
  void _checkWellbeing(final int n) async {
    assert(n >= 1);
    final List<WellbeingItem> items =
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .getLastNDaysAvailable(n + 1);
    if (items.length == n + 1 &&
        _isDecreasing(items.map((item) => item.wellbeingScore).toList())) {
      // if there were enough scores, and they were decreasing
      scheduleNudge();
    }
  }

  /// Gets the actual steps taken accounting for the fact that the user may
  /// have reset their device.
  int _getActualSteps(int currentTotal, int prevTotal) =>
      // using the difference between this week's and last week's steps
      prevTotal > currentTotal ? currentTotal : currentTotal - prevTotal;

  @override
  Widget build(BuildContext context) {
    /// Current Wellbeing Slider
    final slider = Slider(
      value: _currentSliderValueWellbeing,
      min: 0,
      max: 10,
      divisions: 10,
      label: _currentSliderValueWellbeing
          .round() //slider increments are whole numbers
          .toString(),
      activeColor: Theme.of(context).primaryColor,
      inactiveColor: Color.fromARGB(189, 189, 189, 255), //lighter blue
      onChanged: (double value) {
        setState(() {
          _currentSliderValueWellbeing = value;
        });
      },
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      FutureBuilder(
        future: _lastTotalStepsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("Future builder has data");
            final int lastTotalSteps = snapshot.data;
            print("lastTotalSteps: $lastTotalSteps");
            return StreamBuilder(
              stream: widget.stepValueStream,
              builder: (context, streamSnapshot) {
                /// For Deployment change this to how it was
                if (streamSnapshot.hasData) {
                  final currentTotalSteps = streamSnapshot.data;
                  print(currentTotalSteps);
                  final thisWeeksSteps =
                      _getActualSteps(currentTotalSteps, lastTotalSteps);
                  return Column(
                    children: [
                      Text("Your steps this week:",
                          style: Theme.of(context).textTheme.bodyText1),
                      Text(thisWeeksSteps.toString(),
                          style: TextStyle(
                              fontFamily: 'Rosario',
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.secondary)),
                      SizedBox(height: sizeBoxHeight + 20),

                      /// Wellbeing
                      Text("How did you feel this week?",
                          style: Theme.of(context).textTheme.bodyText1),
                      Container(
                        child: SliderTheme(
                            key: Key("Welleing Slider"),
                            data: SliderTheme.of(context).copyWith(
                                valueIndicatorShape:
                                    PaddleSliderValueIndicatorShape()),
                            child: slider),
                      ),
                      SizedBox(height: sizeBoxHeight),

                      /// Sputum Color
                      Text(
                          "Over the past 7 days, rate what color your sputum was.",
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                            valueIndicatorShape:
                                PaddleSliderValueIndicatorShape()),
                        child: Slider(
                          value: _currentSliderValueSputumColor,
                          min: 0,
                          max: 4,
                          divisions: 4,
                          label:
                              _currentSliderValueSputumColor.round().toString(),
                          activeColor: Theme.of(context).colorScheme.primary,
                          inactiveColor: Color.fromARGB(189, 189, 189, 255),
                          onChanged: (double value) {
                            setState(() {
                              _currentSliderValueSputumColor = value;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(246, 247, 249, 1),
                                  border: Border.all(color: Colors.grey)),
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(253, 250, 243, 1.0),
                                  border: Border.all(color: Colors.grey)),
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(252, 250, 227, 1),
                                  border: Border.all(color: Colors.grey)),
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(220, 219, 188, 1),
                                  border: Border.all(color: Colors.grey)),
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(211, 206, 125, 1),
                                  border: Border.all(color: Colors.grey)),
                              height: 50,
                              width: 50,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizeBoxHeight),

                      /// MRC Dysonea Scale
                      Container(
                        key: Key('MRCDysoneaScale'),
                        child: Column(
                          children: [
                            Text(
                                "Over the past 7 days, rate your level of breathlessness.",
                                style: Theme.of(context).textTheme.bodyText1,
                                textAlign: TextAlign.center),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                      descriptionsMRCDyspnoeaScale[
                                          _currentSliderValueMRCDyspnoeaScale
                                              .toInt()],
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                            Container(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    valueIndicatorShape:
                                        PaddleSliderValueIndicatorShape(),
                                    valueIndicatorTextStyle: TextStyle(
                                        overflow: TextOverflow.ellipsis)),
                                child: Slider(
                                  value: _currentSliderValueMRCDyspnoeaScale,
                                  min: 0,
                                  max: 4,
                                  divisions: 4,
                                  activeColor:
                                      Theme.of(context).colorScheme.primary,
                                  inactiveColor:
                                      Color.fromARGB(189, 189, 189, 255),
                                  onChanged: (double newValue) {
                                    setState(() {
                                      _currentSliderValueMRCDyspnoeaScale =
                                          newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      AudioRecording(
                          audioFileLocationURL: _currentValueAudioURL,
                          currentValueSpeechRateTest:
                              _currentValueSpeechRateTest,
                          currentValueTestDuration: _currentValueTestDuration,
                          callback: callback),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final dateString = // get date with fakeable clock
                                clock.now().toIso8601String().substring(0, 10);

                            await Provider.of<UserWellbeingDB>(context,
                                    listen: false)
                                .insertWithData(
                                    date: dateString,
                                    postcode: await _getPostcode(),
                                    wellbeingScore:
                                        _currentSliderValueWellbeing,
                                    sputumColour:
                                        _currentSliderValueSputumColor,
                                    mrcDyspnoeaScale:
                                        _currentSliderValueMRCDyspnoeaScale,
                                    speechRateTest: _currentValueSpeechRateTest,
                                    testDuration: _currentValueTestDuration,
                                    speechRate: _currentValueSpeechRate,
                                    audioURL: _currentValueAudioURL,
                                    numSteps: thisWeeksSteps,
                                    supportCode: await _getSupportCode());
                            SharedPreferences.getInstance().then((value) =>
                                value.setInt(
                                    PREV_STEP_COUNT_KEY, currentTotalSteps));

                            Navigator.pop(context);

                            _checkWellbeing(
                                2); // nudges if scores dropped twice
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.secondary)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else if (streamSnapshot.hasError) {
                  print(streamSnapshot.error);
                  return Text('Could not retrieve step count.');
                }
                return LinearProgressIndicator();
              },
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text("Something went wrong...",
                style: TextStyle(
                    fontFamily: 'Rosario',
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.secondary));
          }
          return CircularProgressIndicator();
        },
      ),
    ]);
  }

  /// Disposing Audio Recorder
  @override
  void dispose() {
    super.dispose();
  }
}
