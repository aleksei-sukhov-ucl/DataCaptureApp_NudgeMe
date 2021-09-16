import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:nudge_me/background.dart';
import 'package:nudge_me/crypto.dart';
import 'package:nudge_me/main.dart';
import 'package:nudge_me/main_pages.dart';
import 'package:nudge_me/shared/audio_recording.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nudge_me/notification.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nudge_me/pages/settings_sections/reschedule_wb.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen that displays to faciliate the user setup.
/// Also schedules the wbCheck/share notifications here to ensure that
/// its only done once.
class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: IntroScreenWidgets());
  }
}

class IntroScreenWidgets extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IntroScreenWidgetsState();
}

class _IntroScreenWidgetsState extends State<IntroScreenWidgets> {
  @override
  initState() {
    _permissionsRequest();
    super.initState();
  }

  void _permissionsRequest() async {
    await Permission.sensors.request();
    await Permission.activityRecognition.request();
    await Permission.microphone.request();
  }

  /// Keeps track of the postcode [TextField]
  final postcodeController = TextEditingController();

  /// Keeps track of the support code [TextField]
  final supportCodeController = TextEditingController();

  /// List of descriptions of MRC Dyspnoea Scale
  final List<String> descriptionsMRCDyspnoeaScale = [
    "Not troubled by breathless except on strenuous exercise",
    "Short of breath when hurrying on a level or when walking up a slight hill",
    "Walks slower than most people on the level, stops after a mile or so, or stops after 15 minutes walking at own pace",
    "Stops for breath after walking 100 yards, or after a few minutes on level ground",
    "Too breathless to leave the house, or breathless when dressing/undressing"
  ];

  /// Default values for silder, switch, and notification day, hour and min.
  double _currentSliderValueWellbeing = 0;
  double _currentSliderValueSputumColor = 0;
  double _currentSliderValueMRCDyspnoeaScale = 0;
  int _currentValueSpeechRateTest = 0;
  double _currentValueTestDuration = 30;
  double _currentValueSpeechRate = 0;
  String _currentValueAudioURL;
  bool _currentSwitchValue = false;
  int _wbCheckNotifDay = DateTime.sunday;
  int _wbCheckNotifHour = 12;
  int _wbCheckNotifMinute = 0;
  DateTime _wbCheckNotifTime;

  /// true if done was tapped with valid input
  bool doneTapped = false;

  /// TODO Create forms/pages for missing data
  /// Records first wellbeing check
  void setInitialWellbeing(
    double _currentSliderValueWellbeing,
    double _currentSliderValueSputumColor,
    double _currentSliderValueMRCDyspnoeaScale,
    int _currentValueSpeechRateTest,
    double _currentValueTestDuration,
    double _currentValueSpeechRate,
    String _currentValueAudioURL,
    String postcode,
    String suppCode,
  ) async {
    final dateString = clock.now().toIso8601String().substring(0, 10);
    await Provider.of<UserWellbeingDB>(context, listen: false).insertWithData(
      date: dateString,
      postcode: postcode,
      numSteps: 0,
      wellbeingScore: _currentSliderValueWellbeing,
      sputumColour: _currentSliderValueSputumColor,
      mrcDyspnoeaScale: _currentSliderValueMRCDyspnoeaScale,
      speechRateTest: _currentValueSpeechRateTest,
      testDuration: _currentValueTestDuration,
      speechRate: _currentValueSpeechRate,
      audioURL: _currentValueAudioURL,
      supportCode: suppCode,
    );
  }

  /// Saves user input: postcode, support code and notification time.
  void _saveInput(
      String postcode,
      String suppcode,
      double _currentSliderValueWellbeing,
      double _currentSliderValueSputumColor,
      double _currentSliderValueMRCDyspnoeaScale,
      int _currentValueSpeechRateTest,
      double _currentValueTestDuration,
      double _currentValueSpeechRate,
      String _currentValueAudioURL,
      DateTime _wbCheckNotifTime) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('postcode', postcode);
    prefs.setString('support_code', suppcode);
    String _wbCheckNotifString = _wbCheckNotifTime.toIso8601String();
    prefs.setString('wb_notif_time', _wbCheckNotifString);

    setInitialWellbeing(
        _currentSliderValueWellbeing,
        _currentSliderValueSputumColor,
        _currentSliderValueMRCDyspnoeaScale,
        _currentValueSpeechRateTest,
        _currentValueTestDuration,
        _currentValueSpeechRate,
        _currentValueAudioURL,
        postcode,
        suppcode);
  }

  /// Returns whether postcode and support code are valid lengths
  bool _isInputValid(String postcode, String suppCode) {
    return 2 <= postcode.length && postcode.length <= 4 && suppCode.length > 0;
  }

  /// Carries out setting up notification, crypto and background step counter.
  /// Called at the the end of intro screen.
  Future<void> _finishSetup(
      bool _currentSwitchValue, DateTime _wbCheckNotifTime) async {
    scheduleCheckup(_wbCheckNotifTime.day,
        Time(_wbCheckNotifTime.hour, _wbCheckNotifTime.minute));
    if (_currentSwitchValue) {
      schedulePublish(); //if permission was given, set up weekly sharing data

    }

    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(FIRST_TIME_DONE_KEY, true));

    await setupCrypto();

    // only start tracking steps after user has done setup
    initBackground();
    schedulePedometerInsert();
    schedulePrevStepCountKeyInsert();
  }

  /// Called when intro screen finishes.
  void _onIntroEnd(
      context,
      double _currentSliderValueWellbeing,
      double _currentSliderValueSputumColor,
      double _currentSliderValueMRCDyspnoeaScale,
      int _currentValueSpeechRateTest,
      double _currentValueTestDuration,
      double _currentValueSpeechRate,
      String _currentValueAudioURL,
      bool _currentSwitchValue,
      _wbCheckNotifDay,
      _wbCheckNotifHour,
      _wbCheckNotifMinute) async {
    if (!_isInputValid(
      postcodeController.text,
      supportCodeController.text,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.yellow,
        content: Text("Invalid postcode or support code."),
      ));
      return;
    } else if (doneTapped) {
      // this check is needed so we don't perform multiple setups
      // in case they tap multiple times
      return;
    }
    setState(() {
      doneTapped = true;
    });
    _dismisKeyboard(); // to avoid some rendering issues

    _wbCheckNotifTime = DateTime(
        2020, 1, _wbCheckNotifDay, _wbCheckNotifHour, _wbCheckNotifMinute);

    _saveInput(
        postcodeController.text.toUpperCase(),
        supportCodeController.text.toUpperCase(),
        _currentSliderValueWellbeing,
        _currentSliderValueSputumColor,
        _currentSliderValueMRCDyspnoeaScale,
        _currentValueSpeechRateTest,
        _currentValueTestDuration,
        _currentValueSpeechRate,
        _currentValueAudioURL,
        _wbCheckNotifTime);

    // NOTE: this is the 'proper' way of requesting permissions (instead of
    // just lowering the targetSdkVersion) but it doesn't seem to work and
    // I don't have access to an Android 10 device to further test it

    await _finishSetup(_currentSwitchValue, _wbCheckNotifTime);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainPages()),
    );
  }

  /// Page containing [DropdownButton]s
  /// that choose the day and time for Wellbeing Check notification/
  PageViewModel _getWBCheckNotificationPage(
      context, TextStyle introTextStyle, PageDecoration pageDecoration) {
    final notificationSelector = ListView(
        padding: const EdgeInsets.all(5),
        scrollDirection: Axis.horizontal,
        children: [
          DropdownButton(
            value: _wbCheckNotifDay,
            hint: Text("Day"),
            icon: Icon(Icons.arrow_downward,
                color: Theme.of(context).primaryColor),
            iconSize: 20,
            elevation: 16,
            style: introTextStyle,
            underline: Container(
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
            onChanged: (value) {
              setState(() {
                if (value != null) {
                  _wbCheckNotifDay = value;
                }
              });
            },
            items: <int>[
              DateTime.monday,
              DateTime.tuesday,
              DateTime.wednesday,
              DateTime.thursday,
              DateTime.friday,
              DateTime.saturday,
              DateTime.sunday
            ].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(days[value - 1]),
              );
            }).toList(),
          ),
          SizedBox(width: 10),
          DropdownButton(
              value: _wbCheckNotifHour,
              hint: Text("Hour"),
              icon: Icon(Icons.arrow_downward,
                  color: Theme.of(context).primaryColor),
              iconSize: 20,
              elevation: 16,
              style: introTextStyle,
              underline: Container(
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _wbCheckNotifHour = value;
                  }
                });
              },
              items: hours.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString().padLeft(2, "0")),
                );
              }).toList()),
          SizedBox(width: 5),
          DropdownButton(
              value: _wbCheckNotifMinute,
              hint: Text("Minutes"),
              icon: Icon(Icons.arrow_downward,
                  color: Theme.of(context).primaryColor),
              iconSize: 20,
              elevation: 16,
              style: introTextStyle,
              underline: Container(
                height: 2,
                color: Theme.of(context).primaryColor,
              ),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    _wbCheckNotifMinute = value;
                  }
                });
              },
              items: minutes.map<DropdownMenuItem>((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value.toString().padLeft(2, "0")),
                );
              }).toList())
        ]);
    return PageViewModel(
        title: "Wellbeing Check Notification",
        image: Center(
            child: Image.asset("lib/images/IntroWBCheckNotification.png",
                height: 225.0)),
        bodyWidget: Column(
          children: [
            Text(
                "When do you want to receive your weekly Wellbeing Check notification?",
                style: introTextStyle,
                textAlign: TextAlign.center),
            SizedBox(height: 5),
            Center(
                child: Container(
              height: 60,
              child: notificationSelector,
            )),
          ],
        ),
        decoration: pageDecoration);
  }

  callback(String audioFileLocationURL, int currentValueSpeechRateTest,
      double currentValueTestDuration) {
    setState(() {
      _currentValueAudioURL = audioFileLocationURL;
      _currentValueSpeechRateTest = currentValueSpeechRateTest;
      _currentValueTestDuration = currentValueTestDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Introduction pages - page design settings
    double width = MediaQuery.of(context).size.width;
    TextStyle introTextStyle =
        TextStyle(fontSize: width * 0.045, color: Colors.black);
    TextStyle introHintStyle =
        TextStyle(fontSize: width * 0.045, color: Colors.grey);

    const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 27.0, fontWeight: FontWeight.w700),
        descriptionPadding: EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 0.0),
        pageColor: Color.fromARGB(255, 251, 249, 255),
        imagePadding: EdgeInsets.zero,
        footerPadding: EdgeInsets.symmetric(vertical: 10.0));

    /// Introduction pages - progress dots design settings
    const dotIndicatorSettings = DotsDecorator(
      size: Size.square(4.4),
      spacing: const EdgeInsets.symmetric(horizontal: 3.0),
      color: Color(0xFFBDBDBD),
      activeColor: Color.fromARGB(255, 0, 74, 173),
      activeSize: Size.square(7.0),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );

    Widget sputumColourDescription = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(246, 247, 249, 1),
              border: Border.all(color: Colors.grey)),
          height: 50,
          width: 50,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(253, 250, 243, 1.0),
              border: Border.all(color: Colors.grey)),
          height: 50,
          width: 50,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(252, 250, 227, 1),
              border: Border.all(color: Colors.grey)),
          height: 50,
          width: 50,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(220, 219, 188, 1),
              border: Border.all(color: Colors.grey)),
          height: 50,
          width: 50,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color.fromRGBO(211, 206, 125, 1),
              border: Border.all(color: Colors.grey)),
          height: 50,
          width: 50,
        ),
      ],
    );

    /// First Page
    PageViewModel firstPage = PageViewModel(
        title: "Welcome",
        image: Image.asset("lib/images/IntroLogo2RegularInline.png"),
        // image: Image.asset("lib/images/launcher/logo.png"),
        bodyWidget: Text(
            "It is recognised that people often forget to look after themselves. \n\n " +
                "NudgeShare has been designed to encourage you to do this. \n \n",
            style: introTextStyle,
            textAlign: TextAlign.center),
        decoration: pageDecoration);

    /// Second Page
    PageViewModel secondPage = PageViewModel(
        title: "How?",
        // image: Image.asset("lib/images/IntroLogo.png"),
        image: Image.asset("lib/images/IntroLogo2RegularInline.png"),
        bodyWidget: Text(
            "Occasionally, it will nudge you to keep in contact with people you like to speak to. " +
                "It will also make you aware of opportunities to share your wellbeing with this group. " +
                "\n\nIf you consent to this, swipe left.",
            style: introTextStyle,
            textAlign: TextAlign.center),
        decoration: pageDecoration);

    ///Third Page
    PageViewModel wellbeingPage = PageViewModel(
        title: "Wellbeing Check",
        image: Center(
            child: Icon(
          Icons.emoji_people_rounded,
          size: 225,
          color: Theme.of(context).colorScheme.secondary,
        )),
        bodyWidget:
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
              "This is your first wellbeing check. NudgeShare will enable you to keep a weekly record of your wellbeing and allow you to understand the importance of movement in your life.",
              style: introTextStyle,
              textAlign: TextAlign.center),
          Text(
              "\n Over the past 7 days, rate how well you have felt out of 10. ",
              style: introTextStyle,
              textAlign: TextAlign.center),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("Confused? Find additional instructions below.",
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center),
          ),
          Container(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    valueIndicatorShape: PaddleSliderValueIndicatorShape()),
                child: Slider(
                  value: _currentSliderValueWellbeing,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: _currentSliderValueWellbeing.round().toString(),
                  activeColor: Theme.of(context).primaryColor,
                  inactiveColor: Color.fromARGB(189, 189, 189, 255),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValueWellbeing = value;
                    });
                  },
                ),
              ),
              width: 300.0),
          Text(
              "Move the purple circle up or down the scale to log how you feel." +
                  " (On the scale, 0 is the lowest score and 10 is the highest score)",
              style: introTextStyle,
              textAlign: TextAlign.center),
          SizedBox(height: 15),
        ]),
        decoration: pageDecoration);

    ///Fourth Page
    PageViewModel sputumColorPage = PageViewModel(
        title: "Sputum Color Check",
        image: ColorFiltered(
            child: Image.asset(
              "lib/images/Lungs.png",
              scale: 2,
            ),
            colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.secondary, BlendMode.srcATop)),
        bodyWidget:
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
              "This is your first sputum color check.\nSputum that is a "
              "different color from saliva may be a sign of a "
              "Respiratory Tract Infections (RTIs).",
              style: introTextStyle,
              textAlign: TextAlign.center),
          Text("\n Over the past 7 days, rate what color your sputum was. ",
              style: introTextStyle, textAlign: TextAlign.center),
          Container(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    valueIndicatorShape: PaddleSliderValueIndicatorShape()),
                child: Slider(
                  value: _currentSliderValueSputumColor,
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: _currentSliderValueSputumColor.round().toString(),
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Color.fromARGB(189, 189, 189, 255),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValueSputumColor = value;
                    });
                  },
                ),
              ),
              width: 340.0),
          sputumColourDescription
        ]),
        decoration: pageDecoration);

    ///Fifth Page - MRC Dysonea Scale
    PageViewModel mrcDysoneaScalePage = PageViewModel(
        title: "Breathlessness Check",
        image: Center(
            child: Icon(
          Icons.directions_walk_rounded,
          size: 225,
          color: Theme.of(context).colorScheme.secondary,
        )),
        bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "This is your first breathlessness check.\nThe Dyspnoea Scale is used for grading the effect of breathlessness on daily activities.",
                  style: introTextStyle,
                  textAlign: TextAlign.center),
              Text(
                  "\n Over the past 7 days, rate your level of breathlessness.",
                  style: introTextStyle,
                  textAlign: TextAlign.center),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      color: Theme.of(context).colorScheme.primary),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                        descriptionsMRCDyspnoeaScale[
                            _currentSliderValueMRCDyspnoeaScale.toInt()],
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  ),
                ),
              ),
              Container(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                        valueIndicatorTextStyle:
                            TextStyle(overflow: TextOverflow.ellipsis)),
                    child: Slider(
                      value: _currentSliderValueMRCDyspnoeaScale,
                      min: 0,
                      max: 4,
                      divisions: 4,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Color.fromARGB(189, 189, 189, 255),
                      onChanged: (double newValue) {
                        setState(() {
                          _currentSliderValueMRCDyspnoeaScale = newValue;
                        });
                      },
                    ),
                  ),
                  width: 340.0),
            ]),
        decoration: pageDecoration);

    ///SixthPage - Speech Rate
    PageViewModel speechRatePage = PageViewModel(
        title: "Speech Rate Check",
        image: Center(
            child: Icon(
          Icons.record_voice_over_rounded,
          size: 225,
          color: Theme.of(context).colorScheme.secondary,
        )),
        bodyWidget: AudioRecording(
            audioFileLocationURL: _currentValueAudioURL,
            currentValueSpeechRateTest: _currentValueSpeechRateTest,
            currentValueTestDuration: _currentValueTestDuration,
            callback: callback),
        decoration: pageDecoration);

    PageViewModel shareData = PageViewModel(
        title: "Share Data",
        image: Center(
            child: Image.asset("lib/images/IntroShare.png", height: 225.0)),
        bodyWidget:
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Switch(
              value: _currentSwitchValue,
              onChanged: (value) {
                setState(() {
                  _currentSwitchValue = value;
                });
              }),
          Text(
              "Click the toggle to consent to the creation of a map that enables you and other app " +
                  "users to understand the effect of movement and social contact has on people's wellbeing. " +
                  "By consenting, you will not be sharing personally identifiable data. " +
                  "All data used to create the map will be anonymised to protect privacy.\n",
              style: introTextStyle,
              textAlign: TextAlign.center),
        ]),
        decoration: pageDecoration);

    PageViewModel postCodeSupportCode = PageViewModel(
        title: "Postcode and Support Code",
        image: Center(
            child: Image.asset("lib/images/IntroPostcode.png", height: 225.0)),
        bodyWidget:
            (Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("What is your support code?",
              style: introTextStyle, textAlign: TextAlign.center),
          TextField(
            controller: supportCodeController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter support code here",
                hintStyle: introHintStyle),
          ),
          Text("If you do not have a support code, type selfhelp",
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          Text("What is the first half of your postcode?",
              style: introTextStyle, textAlign: TextAlign.center),
          TextField(
            controller: postcodeController,
            textAlign: TextAlign.center,
            // https://github.com/flutter/flutter/issues/67236
            maxLength: 4, // length of a postcode prefix
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter postcode here",
                hintStyle: introHintStyle),
          ),
          RichText(
              text: new TextSpan(children: [
                new TextSpan(
                    text:
                        "This will help app users to understand the general wellbeing of people in a region - ",
                    style: Theme.of(context).textTheme.caption),
                new TextSpan(
                    text: "see here",
                    style: TextStyle(
                        fontFamily: 'Rosario',
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Colors.black),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launch(BASE_URL + '/map');
                      })
              ]),
              textAlign: TextAlign.center),
          SizedBox(height: 10),
        ])),
        decoration: pageDecoration);

    return IntroductionScreen(
        pages: [
          firstPage,
          secondPage,
          wellbeingPage,
          sputumColorPage,
          mrcDysoneaScalePage,
          speechRatePage,
          _getWBCheckNotificationPage(context, introTextStyle, pageDecoration),
          shareData,
          postCodeSupportCode
        ],
        onDone: () => _onIntroEnd(
              context,
              _currentSliderValueWellbeing,
              _currentSliderValueSputumColor,
              _currentSliderValueMRCDyspnoeaScale,
              _currentValueSpeechRateTest,
              _currentValueTestDuration,
              _currentValueSpeechRate,
              _currentValueAudioURL,
              _currentSwitchValue,
              _wbCheckNotifDay,
              _wbCheckNotifHour,
              _wbCheckNotifMinute,
            ),
        showSkipButton: false,
        next: const Icon(Icons.arrow_forward,
            color: Color.fromARGB(255, 182, 125, 226)),
        done: !doneTapped
            ? const Text('Done',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 182, 125, 226)))
            : CircularProgressIndicator(),
        onChange: (int _) => _dismisKeyboard(),
        dotsDecorator: dotIndicatorSettings);
  }

  /// If keyboard is open, closes it when user changes pages.
  void _dismisKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      // unfocusing dismisses the keyboard
      currentFocus.unfocus();
    }
  }

  //Disposes of [TextEditingController.]
  void dispose() {
    postcodeController.dispose();
    supportCodeController.dispose();
    super.dispose();
  }
}
