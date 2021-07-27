import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nudge_me/model/user_model.dart';
import 'package:nudge_me/shared/cards.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddData extends StatefulWidget {
  final CardClass card;
  const AddData({Key key, this.card}) : super(key: key);

  @override
  _AddDataState createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  double _currentSliderValueWellbeing = 0;
  double _currentSliderValueSputumColor = 1;
  double _currentSliderValueMRCDyspnoeaScale = 1;
  int _currentValueSpeechRateTest = 0;
  double _currentValueTestDuration = 30;
  double _currentValueSpeechRate = 0;
  String _currentValueAudioURL = "url/test";
  DateTime selectedDate = DateTime.now();
  bool _speechRateTest = false;

  final List<String> descriptionsMRCDyspnoeaScale = [
    "Not troubled by breathless except on strenuous exercise",
    "Short of breath when hurrying on a level or when walking up a slight hill",
    "	Walks slower than most people on the level, stops after a mile or so, or stops after 15 minutes walking at own pace",
    "Stops for breath after walking 100 yards, or after a few minutes on level ground",
    "Too breathless to leave the house, or breathless when dressing/undressing  "
  ];

  @override
  initState() {
    super.initState();
  }

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

  Future<bool> _checkIfDataExists({String checkDate}) async {
    bool _dataAlreadyExists =
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .getDataAlreadyExists(checkDate: checkDate);
    return _dataAlreadyExists == true;
  }

  void hideButton() {
    setState(() {
      _speechRateTest = !_speechRateTest;
    });
  }

  speechRateTest() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text("Please select the type of test:",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center),
          ),
          ToggleSwitch(
            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
            initialLabelIndex: _currentValueSpeechRateTest,
            minWidth: MediaQuery.of(context).size.width * 0.34,
            minHeight: MediaQuery.of(context).size.height * 0.04,
            activeBgColors: [
              [Theme.of(context).colorScheme.primary],
              [Theme.of(context).colorScheme.secondary]
            ],
            inactiveBgColor: Colors.grey[100],
            totalSwitches: 2,
            labels: ["Text", "Numbers"],
            // with just animate set to true, default curve = Curves.easeIn
            radiusStyle: true,
            cornerRadius: 15.0,
            onToggle: (index) {
              setState(() {
                _currentValueSpeechRateTest = index;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Text(
              (_currentValueSpeechRateTest == 0)
                  ? "In this test, you will be asked to say \"Hippopotamus\" as many times as possible in a selected time "
                  : "In this test, you will be asked to count from one onwards until the time runs out",
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text("Please select the duration of test:",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: DropdownButton<int>(
                  value: _currentValueTestDuration.toInt(),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color.fromRGBO(113, 101, 226, 1)),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (int newValue) {
                    setState(() {
                      _currentValueTestDuration = newValue.toDouble();
                      print(
                          "_currentValueTestDuration: $_currentValueTestDuration");
                    });
                  },
                  items: <int>[
                    30,
                    60,
                    90,
                    120,
                  ].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString(),
                          style: Theme.of(context).textTheme.bodyText1,
                          textAlign: TextAlign.center),
                    );
                  }).toList(),
                ),
              ),
              Text("Seconds",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: !_speechRateTest
                ? ElevatedButton(
                    onPressed: () {
                      _currentValueSpeechRate = 185;
                      hideButton();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Start Test",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .merge(TextStyle(color: Colors.white)),
                          textAlign: TextAlign.center),
                    ))
                : Text("${_currentValueSpeechRate.truncate()}  Words/min"),
          )
        ]);
  }

  Widget addingIndividualData({int cardId}) {
    switch (cardId) {
      case 1:
        return Container(
          width: 300,
          child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("\n Rate how well you have felt today out of 10. ",
                    textAlign: TextAlign.center),
                Container(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          valueIndicatorShape:
                              PaddleSliderValueIndicatorShape()),
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
                    width: 300.0)
              ]),
        );
      case 2:
        return Container(
            width: 300,
            child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Rate what color your sputum was today. ",
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        valueIndicatorShape: PaddleSliderValueIndicatorShape()),
                    child: Slider(
                      value: _currentSliderValueSputumColor,
                      min: 1,
                      max: 5,
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
                ]));
      case 3:
        return Container(
            width: 300,
            child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text("Rate your level of breathlessness today.",
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                    child: Container(
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
                                _currentSliderValueMRCDyspnoeaScale.toInt() -
                                    1],
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
                          valueIndicatorTextStyle:
                              TextStyle(overflow: TextOverflow.ellipsis)),
                      child: Slider(
                        value: _currentSliderValueMRCDyspnoeaScale,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Color.fromARGB(189, 189, 189, 255),
                        onChanged: (double newValue) {
                          setState(() {
                            _currentSliderValueMRCDyspnoeaScale = newValue;
                            print(
                                "_currentSliderValueSputumColor: $_currentSliderValueMRCDyspnoeaScale");
                          });
                        },
                      ),
                    ),
                  ),
                ]));
      case 4:
        return Container(
            width: 300,
            child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [speechRateTest()]));
      default:
        Text("No data to add...");
    }
  }

  // _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(2000),
  //       lastDate: DateTime.now(),
  //       initialEntryMode: DatePickerEntryMode.calendarOnly,
  //       builder: (BuildContext context, Widget child) {
  //         return Theme(
  //           data: ThemeData.light().copyWith(
  //             colorScheme: ColorScheme.fromSwatch(),
  //           ),
  //           child: child,
  //         );
  //       });
  //   if (picked != null && picked != selectedDate)
  //     setState(() {
  //       selectedDate = picked;
  //     });
  // }

  insertData({int cardId}) async {
    switch (cardId) {
      case 1:
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .insertWithData(
                date: selectedDate.toIso8601String().substring(0, 10),
                postcode: await _getPostcode(),
                numSteps: null,
                wellbeingScore: _currentSliderValueWellbeing,
                sputumColour: null,
                mrcDyspnoeaScale: null,
                speechRate: null,
                speechRateTest: null,
                testDuration: null,
                audioURL: null,
                supportCode: await _getSupportCode());
        break;
      case 2:
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .insertWithData(
                date: selectedDate.toIso8601String().substring(0, 10),
                postcode: await _getPostcode(),
                numSteps: null,
                wellbeingScore: null,
                sputumColour: _currentSliderValueSputumColor,
                mrcDyspnoeaScale: null,
                speechRate: null,
                speechRateTest: null,
                testDuration: null,
                audioURL: null,
                supportCode: await _getSupportCode());
        break;
      case 3:
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .insertWithData(
                date: selectedDate.toIso8601String().substring(0, 10),
                postcode: await _getPostcode(),
                wellbeingScore: null,
                numSteps: null,
                sputumColour: null,
                mrcDyspnoeaScale: _currentSliderValueMRCDyspnoeaScale,
                speechRate: null,
                speechRateTest: null,
                testDuration: null,
                audioURL: null,
                supportCode: await _getSupportCode());
        break;
      case 4:
        await Provider.of<UserWellbeingDB>(context, listen: false)
            .insertWithData(
                date: selectedDate.toIso8601String().substring(0, 10),
                postcode: await _getPostcode(),
                wellbeingScore: null,
                numSteps: null,
                sputumColour: null,
                mrcDyspnoeaScale: null,
                speechRate: _currentValueSpeechRate,
                speechRateTest: _currentValueSpeechRateTest,
                testDuration: _currentValueTestDuration,
                audioURL: _currentValueAudioURL,
                supportCode: await _getSupportCode());
        break;
    }
  }

  updateData({int cardId}) async {
    switch (cardId) {
      case 1:
        int id = await Provider.of<UserWellbeingDB>(context, listen: false)
            .update(
                columnId: 4,
                value: _currentSliderValueWellbeing,
                Date: DateTime.now().toIso8601String().substring(0, 10));
        print(id);
        return id;
      case 2:
        int id = await Provider.of<UserWellbeingDB>(context, listen: false)
            .update(
                columnId: 5,
                value: _currentSliderValueSputumColor,
                Date: DateTime.now().toIso8601String().substring(0, 10));
        return id;
      case 3:
        int id = await Provider.of<UserWellbeingDB>(context, listen: false)
            .update(
                columnId: 6,
                value: _currentSliderValueMRCDyspnoeaScale,
                Date: DateTime.now().toIso8601String().substring(0, 10));
        return id;
      case 4:
        int id = await Provider.of<UserWellbeingDB>(context, listen: false)
            .updateSpeechTest(
                currentValueSpeechRateTest: _currentValueSpeechRateTest,
                currentValueTestDuration: _currentValueTestDuration,
                currentValueSpeechRate: _currentValueSpeechRate,
                currentValueAudioURL: _currentValueAudioURL,
                Date: DateTime.now().toIso8601String().substring(0, 10));
        return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    // // _checkIfDataExists(
    // //     checkDate: DateTime.now().toIso8601String().substring(0, 10));
    // print(_checkIfDataExists(
    //     checkDate: DateTime.now().toIso8601String().substring(0, 10)));
    // // print("_dataAlreadyExists: $_dataAlreadyExists");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add ${widget.card.titleOfCard} Data",
          style: Theme.of(context).textTheme.subtitle1.merge(
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: Center(
        child: Container(
          width: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //   onPressed: () => _selectDate(context), // Refer step 3
                  //   child: Text(
                  //     'Select date',
                  //     style: TextStyle(
                  //         color: Colors.white, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                  // Text(
                  //   "${selectedDate.toLocal()}".split(' ')[0],
                  //   style: Theme.of(context).textTheme.subtitle1,
                  // ),
                ],
              ),
              addingIndividualData(cardId: widget.card.cardId),
              ElevatedButton(
                onPressed: () async {
                  bool check = await _checkIfDataExists(
                      checkDate:
                          DateTime.now().toIso8601String().substring(0, 10));
                  (check)
                      ? updateData(cardId: widget.card.cardId)
                      : insertData(cardId: widget.card.cardId);

                  Navigator.pop(context);
                }, // Refer step 3
                child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
