import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nudge_me/shared/audio_recording.dart';

void main() {
  // This part mitigates Widget test failing with No MediaQuery widget found
  Widget createWidgetForTesting({Widget child}) {
    return MaterialApp(home: Scaffold(body: SafeArea(child: child)));
  }

  testWidgets('Test to find test selection slider',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: SingleChildScrollView(child: AudioRecording())));
    await tester.pumpAndSettle();

    final textTest = find.text("Text");
    final numbersTest = find.text("Numbers");

    expect(textTest, findsOneWidget);
    expect(numbersTest, findsOneWidget);
  });

  testWidgets('Test to find test duration selector',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: SingleChildScrollView(child: AudioRecording())));
    await tester.pumpAndSettle();

    final secondsTextTest = find.text("Seconds");
    final durationNumberTest = find.text("30");

    expect(secondsTextTest, findsOneWidget);
    expect(durationNumberTest, findsOneWidget);
  });

  testWidgets('Recording Button Test - initial loading',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: SingleChildScrollView(child: AudioRecording())));
    await tester.pumpAndSettle();

    // Finding start recording text
    final scoreFinder = find.text("Waiting to record");
    // Finding Initial Recording Icon
    final audioRecordingButton = find.byIcon(Icons.mic_none_rounded);
    expect(scoreFinder, findsOneWidget);
    expect(audioRecordingButton, findsOneWidget);
  });
}
