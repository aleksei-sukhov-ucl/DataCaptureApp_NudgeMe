import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class textToSpeechPage extends StatefulWidget {
  const textToSpeechPage({Key key}) : super(key: key);

  @override
  _textToSpeechPageState createState() => _textToSpeechPageState();
}

class _textToSpeechPageState extends State<textToSpeechPage> {
  static const platform = const MethodChannel("com.flutter.tts/tts");

  void Printy() async {
    String value;
    try {
      value = await platform.invokeMethod("Printy");
    } catch (e) {
      print(e);
    }

    print(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: TextButton(
        child: const Text('Disabled'),
        onPressed: () {
          Printy();
        },
      ),
    ));
  }
}
