import 'dart:ui';

import 'package:flutter/material.dart';

/// Defining the class for cards
class CardClass {
  int cardId;
  dynamic cardIcon;
  String titleOfCard;
  String units;
  Color color;
  Widget cardDescription;

  CardClass(
      {this.cardId,
      this.cardIcon,
      this.titleOfCard,
      this.units,
      this.color,
      this.cardDescription});
}

/// Defining the list of cards
List<CardClass> cards = [
  /// Steps Card
  /// Text ref: https://www.betterhealth.vic.gov.au/health/healthyliving/walking-for-good-health
  CardClass(
    cardId: 0,
    cardIcon: Icon(Icons.directions_walk),
    titleOfCard: "Steps",
    units: "Steps",
    color: Color.fromRGBO(123, 230, 236, 1),
    cardDescription: Text("Walking for 30 minutes a day or more"
        " on most days of the week is a great way"
        " to improve or maintain your overall health."
        "\n\nIf you can’t manage 30 minutes a day, "
        "remember ‘even a little is good, but more"
        " is better’.\n\nWalking with others can turn"
        " exercise into an enjoyable social occasion."),
  ),

  ///Wellbeing Score Card
  CardClass(
      cardId: 1,
      cardIcon: Icon(Icons.accessibility_new),
      titleOfCard: "Wellbeing Score",
      units: "Wellbeing score",
      color: Colors.deepPurple,
      cardDescription: Text("")),

  ///Sputum Color Card
  CardClass(
    cardId: 2,
    cardIcon: Icon(Icons.sentiment_satisfied_alt),
    titleOfCard: "Sputum colour",
    units: "Sputum Color",
    color: Color.fromRGBO(251, 222, 147, 1),
    cardDescription: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Text(
                "Sputum is produced when a person’s lungs are diseased or damaged. Sputum is not saliva but the thick mucus – sometimes called phlegm – which is coughed up from the lungs.\n\nThe body produces mucus to keep the thin, delicate tissues of the respiratory tract moist so that small particles of foreign matter that may pose a threat can be trapped and forced out.\n\nSometimes, such as when there is an infection in the lungs, an excess of mucus is produced. The body attempts to get rid of this excess by coughing it up as sputum."),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(246, 247, 249, 1),
                    border: Border.all(color: Colors.grey)),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "0",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(253, 250, 243, 1.0),
                    border: Border.all(color: Colors.grey)),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "1",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(252, 250, 227, 1),
                    border: Border.all(color: Colors.grey)),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "2",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(220, 219, 188, 1),
                    border: Border.all(color: Colors.grey)),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "3",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(211, 206, 125, 1),
                    border: Border.all(color: Colors.grey)),
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "4",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          )
        ]),
  ),

  /// Text ref: https://www.medicalnewstoday.com/articles/318924
  CardClass(
      cardId: 3,
      cardIcon: ImageIcon(
        AssetImage("lib/images/Lungs.png"),
        size: 24,
      ),
      titleOfCard: "MRC Dyspnoea Scale",
      units: "MRC Dyspnoea Score",
      color: Color.fromRGBO(138, 127, 245, 1),
      cardDescription: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("The dyspnoea scale has been in use for many years for grading "
              "the effect of breathlessness on daily activities. This scale"
              " measures perceived respiratory disability.\n\nThe MRC dyspnoea"
              " scale is simple to administer as it allows the patients to "
              "indicate the extent to which their breathlessness affects"
              " their mobility."),
          SizedBox(
            height: 10,
          ),
          mrcDescriptionKey(
              description:
                  "Not troubled by breathless except on strenuous exercise",
              id: "0"),
          mrcDescriptionKey(
              description: "Short of breath when hurrying on a level or "
                  "when walking up a slight hill",
              id: "1"),
          mrcDescriptionKey(
              description:
                  "Walks slower than most people on the level, stops after "
                  "a mile or so, or stops after 15 minutes walking at own pace",
              id: "2"),
          mrcDescriptionKey(
              description: "Stops for breath after walking 100 yards, or"
                  " after a few minutes on level ground",
              id: "3"),
          mrcDescriptionKey(
              description: "Too breathless to leave the house, "
                  "or breathless when dressing/undressing",
              id: "4"),
        ],
      )

      ///Text ref: https://mrc.ukri.org/research/facilities-and-resources-for-researchers/mrc-scales/mrc-dyspnoea-scale-mrc-breathlessness-scale/
      ),

  ///Speech to text card
  // CardClass(
  //   cardId: 4,
  //   cardIcon: Icon(Icons.record_voice_over),
  //   titleOfCard: "Speech Rate",
  //   units: "Words/min",
  //   color: Color.fromRGBO(241, 139, 128, 1.0),
  //   cardDescription: Text(""),
  // ),

  /// Trends card
  CardClass(
      cardId: 5,
      cardIcon: Icon(Icons.timeline_outlined),
      titleOfCard: "Trends",
      units: "Trends",
      color: Colors.pinkAccent,
      cardDescription:
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        cardKey(color: Color.fromRGBO(123, 230, 236, 1), text: "Steps"),
        cardKey(color: Colors.deepPurple, text: "Wellbeing Score"),
        cardKey(color: Color.fromRGBO(251, 222, 147, 1), text: "Sputum colour"),
        cardKey(
            color: Color.fromRGBO(138, 127, 245, 1),
            text: "MRC Dyspnoea Scale"),
        // cardKey(color: Color.fromRGBO(241, 139, 128, 1.0), text: "Speech Rate")
      ]))
];

Widget cardKey({Color color, String text}) {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color,
          ),
          height: 40,
          width: 40,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(text),
          ),
        ),
      ],
    ),
  );
}

Widget mrcDescriptionKey({String description, String id}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          height: 40,
          width: 40,
          child: Center(child: Text(id)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Container(
            width: 240,
            child: Text(
              description,
              // style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      ],
    ),
  );
}
