import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:record/record.dart';

class AudioRecording extends StatefulWidget {
  final void Function(String path) onStop;
  final String audioFileLocationURL;
  final Function(String, int, double) callback;
  final currentValueSpeechRateTest;
  final currentValueTestDuration;
  const AudioRecording(
      {Key key,
      this.onStop,
      this.audioFileLocationURL,
      this.callback,
      this.currentValueSpeechRateTest,
      this.currentValueTestDuration})
      : super(key: key);

  @override
  _AudioRecordingState createState() => _AudioRecordingState();
}

class _AudioRecordingState extends State<AudioRecording> {
  ///Audio
  int _isRecording = 0;

  /// Is recording can have 4 states:
  /// 0 - not recording
  /// 1 - start recording
  /// 2 - stop recording (by user)
  /// 3 - automatic recording stopped by timer

  bool _isPaused = false;
  int _recordDuration = 30;
  Timer _timer;
  final _audioRecorder = Record();

  ///Test variables
  int _currentValueSpeechRateTest = 0;
  double _currentValueTestDuration = 30;

  @override
  void initState() {
    _isRecording = 0;
    // _checkingPermission();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text("Please select the type of test:",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center),
          ),
          ToggleSwitch(
            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
            initialLabelIndex: _currentValueSpeechRateTest,
            minWidth: MediaQuery.of(context).size.width * 0.35,
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
                  ? "In this test, you will be asked to say \"Hippopotamus\" as many times as possible in a selected time"
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
                      color: Color.fromRGBO(113, 101, 226, 1.0)),
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
            padding: const EdgeInsets.all(8.0),
            child: Text("Press the microphone button to start the recording!",
                textAlign: TextAlign.center),
          ),
          audioRecordingButton(),
          _buildText()
        ]);
  }

  iconSelect(int _isRecording) {
    switch (_isRecording) {
      case 0:
        return Icons.mic_none_rounded;
      case 1:
        return Icons.stop;
      case 2:
        return Icons.refresh_rounded;
      case 3:
        // return Icons.save_rounded;
        return Icons.done_rounded;
      default:
        return Icons.mic_none_rounded;
    }
  }

  // _checkingPermission() async {
  //   final status = await Permission.microphone.request();
  //   print("status: $status");
  //   if (status == PermissionStatus.permanentlyDenied) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         elevation: 10,
  //         backgroundColor: Colors.yellow,
  //         content: Text(
  //             "Please enable access to the microphone in your device settings")));
  //   }
  // }

  iconColorSelect(int _isRecording) {
    switch (_isRecording) {
      case 0:
        return Theme.of(context).colorScheme.secondary;
      case 1:
        return Colors.red;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.greenAccent;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget audioRecordingButton() {
    if (_recordDuration == _currentValueTestDuration && _isRecording == 1) {
      _stopAndSave();
    }
    final icon = iconSelect(_isRecording);
    final buttonColor = iconColorSelect(_isRecording);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: RawMaterialButton(
        key: Key("AudioRecordingButton"),
        fillColor: buttonColor,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
        onPressed: () async {
          switch (_isRecording) {
            case 0:
              _start();
              break;
            case 1:
              _stopAndDelete();
              break;
            case 2:
              setState(() {
                _isRecording = 0;
              });
              break;
            case 3:
              break;
            default:
              break;
          }
        },
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_isRecording == 1 || _isPaused) {
      return _buildTimer();
    } else if (_isRecording == 2) {
      return Text("Please rerecord");
    } else if (_isRecording == 3) {
      return Text("Recording Saved!");
    }

    return Text("Waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0' + numberStr;
    }

    return numberStr;
  }

  Future<String> getFileName() async {
    final directory = await getApplicationDocumentsDirectory();
    String _path =
        "${directory.path}/${DateTime.now().toIso8601String().substring(0, 10)}.m4a";
    return _path;
  }

  Future<void> _start() async {
    String _path = await getFileName();
    // }
    try {
      if (await _audioRecorder.hasPermission()) {
        print("_path: $_path");
        await _audioRecorder.start(path: _path);

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          if (isRecording) {
            _isRecording = 1;
          } else {
            _isRecording = 0;
          }
          _recordDuration = 0;
        });

        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopAndDelete() async {
    _timer.cancel();
    final path = await _audioRecorder.stop();
    final directory = await getApplicationDocumentsDirectory();
    print("directory: $directory");
    print("path:$path");
    print(await File(path /*.split("/").last*/).exists());
    print(await File(path).delete());

    setState(() => _isRecording = 2);
  }

  Future<void> _stopAndSave() async {
    _timer.cancel();
    final path = await _audioRecorder.stop();
    widget.callback(
        path, _currentValueSpeechRateTest, _currentValueTestDuration);

    setState(() => _isRecording = 3);
  }

  /// Auxiliary function for pausing the recording - don't need for current use
  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();

    setState(() => _isPaused = true);
  }

  /// Auxiliary function for resuming the recording - don't need for current use
  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();

    setState(() => _isPaused = false);
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
