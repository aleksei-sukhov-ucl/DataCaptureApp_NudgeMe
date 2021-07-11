import 'package:flutter/material.dart';

/// [StatefulWidget] that takes displays an animated, circular representation of
/// a score
class WellbeingCircle extends StatefulWidget {
  /// 0 <= score <= 10 that determines how much positive/negative color to show
  final int score;
  final Color firstColor;
  final Color secondColor;

  /// takes an [int] score which could be null
  const WellbeingCircle(
      {this.score,
      this.firstColor = Colors.purpleAccent,
      this.secondColor = Colors.blueAccent});

  @override
  _WellbeingCircleState createState() => _WellbeingCircleState();
}

class _WellbeingCircleState extends State<WellbeingCircle> {
  int _currScore = 0;

  @override
  void initState() {
    super.initState();

    // it must be delayed by some amount for it to animate
    Future.delayed(Duration(milliseconds: 100),
        () => setState(() => _currScore = widget.score));
  }

  @override
  Widget build(BuildContext context) {
    // subtracted 2 from score to allow space for larger gradient
    final double purpleFraction =
        (_currScore == null ? 10.0 : _currScore - 2) / 10.0;
    final double blueStartPoint =
        purpleFraction + 0.4 <= 1 ? purpleFraction + 0.4 : 1;

    final boxShadows = [
      // shadow effect around the circle
      BoxShadow(
        color: Colors.grey.withOpacity(0.6),
        spreadRadius: 1,
        blurRadius: 3,
      ),
    ];

    final bgCircle = AnimatedContainer(
      duration: Duration(milliseconds: 900),
      width: MediaQuery.of(context).size.width / 3.1,
      height: MediaQuery.of(context).size.width / 3.1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [widget.firstColor, widget.secondColor],
            // cumulative points to switch color:
            stops: [purpleFraction, blueStartPoint]),
        shape: BoxShape.circle,
        boxShadow: boxShadows,
      ),
    );

    return Stack(
      alignment: Alignment.center, // aligns all to center by default
      children: [
        bgCircle,
        Text(widget.score == null ? "N/A" : widget.score.toString(),
            style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width / 7),
            textDirection: TextDirection.ltr),
      ],
    );
  }
}
