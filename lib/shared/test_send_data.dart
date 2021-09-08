import 'package:flutter/material.dart';

import '../background.dart';

class TestSEnd extends StatefulWidget {
  const TestSEnd({Key key}) : super(key: key);

  @override
  _TestSEndState createState() => _TestSEndState();
}

class _TestSEndState extends State<TestSEnd> {
  @override
  Widget build(BuildContext context) {
    schedulePublish();
    return Scaffold(
      body: ElevatedButton(
          child: Text("Send"),
          onLongPress: () {
            publishData();
          }),
    );
  }
}
