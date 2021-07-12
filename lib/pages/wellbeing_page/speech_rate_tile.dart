import 'package:flutter/material.dart';
import 'package:nudge_me/pages/wellbeing_page/cards.dart';

class SpeechRareTile extends StatefulWidget {
  final CardClass card;
  final int score;
  const SpeechRareTile({Key key, this.card, this.score = 0}) : super(key: key);

  @override
  _SpeechRareTileState createState() => _SpeechRareTileState();
}

class _SpeechRareTileState extends State<SpeechRareTile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: widget.score == null ? "N/A" : widget.score.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
            ),
            TextSpan(text: "words/min", style: TextStyle(fontSize: 8))
          ],
        ),
      ),
    );
  }
}
