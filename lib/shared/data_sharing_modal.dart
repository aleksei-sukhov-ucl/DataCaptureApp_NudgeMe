import 'package:flutter/material.dart';

class DataSharingModal extends StatefulWidget {
  const DataSharingModal({key}) : super(key: key);

  @override
  State<DataSharingModal> createState() => _DataSharingModalState();
}

class _DataSharingModalState extends State<DataSharingModal> {
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
