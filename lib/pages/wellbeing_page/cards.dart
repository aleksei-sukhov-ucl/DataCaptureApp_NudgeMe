import 'package:flutter/material.dart';

/// Defining the class for cards
class CardClass {
  int cardId;
  dynamic cardIcon;
  String titleOfCard;
  int score;
  String units;
  Color color;

  CardClass(
      {this.cardId,
      this.cardIcon,
      this.titleOfCard,
      this.score,
      this.units,
      this.color});
}

/// Defining the list of cards
List<CardClass> cards = [
  CardClass(
      cardId: 0,
      cardIcon: Icon(Icons.directions_walk),
      titleOfCard: "Steps",
      score: 10000,
      units: "Steps",
      color: Colors.greenAccent),
  CardClass(
      cardId: 1,
      cardIcon: Icon(Icons.accessibility_new),
      titleOfCard: "Wellbeing\nScore",
      score: 8,
      units: "Wellbeing score",
      color: Colors.deepPurple),
  CardClass(
      cardId: 2,
      cardIcon: Icon(Icons.sentiment_satisfied_alt),
      titleOfCard: "Sputum\ncolour",
      score: 5,
      units: "Color",
      color: Colors.yellowAccent),
  CardClass(
      cardId: 3,
      cardIcon: ImageIcon(
        AssetImage("lib/images/634cbe378c7b08daa95fd9197f77b468.png"),
        size: 24,
      ),
      titleOfCard: "MRC Dyspnoea Scale",
      // "MRC Dispnoea Scale",
      score: 9,
      units: "Breathlessness Score",
      color: Colors.cyanAccent),
  CardClass(
      cardId: 4,
      cardIcon: Icon(Icons.record_voice_over),
      titleOfCard: "Speech\nRate",
      score: 60,
      units: "Words/min",
      color: Colors.cyanAccent),
];
