import 'package:flutter/material.dart';
import 'package:nudge_me/shared/cards.dart';

class SpeechRareTile extends StatelessWidget {
  final CardClass card;
  final int score;
  const SpeechRareTile({Key key, this.card, this.score = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      child: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: score == 0 ? "N/A" : score.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
              ),
              TextSpan(text: "words/min", style: TextStyle(fontSize: 8))
            ],
          ),
        ),
      ),
    );
  }
}
