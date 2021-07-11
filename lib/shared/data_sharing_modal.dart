import 'package:flutter/material.dart';

class dataSharingModal extends StatefulWidget {
  const dataSharingModal({key}) : super(key: key);

  @override
  State<dataSharingModal> createState() => _dataSharingModalState();
}

class _dataSharingModalState extends State<dataSharingModal> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

enum timeFrame {
  Week,
  Month,
  Year,
}

enum dataToExport { Steps, Wellbeing, Breathlessness, SpeechRate, SputumColor }
