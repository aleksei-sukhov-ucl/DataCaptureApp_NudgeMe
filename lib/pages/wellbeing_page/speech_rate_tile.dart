import 'package:flutter/material.dart';
import 'package:nudge_me/pages/wellbeing_page/cards.dart';

class SpeechRareTile extends StatefulWidget {
  final CardClass card;
  const SpeechRareTile({Key key, this.card}) : super(key: key);

  @override
  _SpeechRareTileState createState() => _SpeechRareTileState();
}

class _SpeechRareTileState extends State<SpeechRareTile> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 19, 0, 19),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "${widget.card.score}",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                    ),
                    TextSpan(text: "words/min", style: TextStyle(fontSize: 8))
                  ],
                ),
              ),
            )));
  }
}
