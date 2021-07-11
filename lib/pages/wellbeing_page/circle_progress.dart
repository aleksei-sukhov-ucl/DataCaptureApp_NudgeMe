import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CirclePercentIndicator extends StatefulWidget {
  final Color color;
  final int actualValue;
  final int goal;
  final String units;
  const CirclePercentIndicator(
      {Key key, this.color, this.actualValue, this.goal, this.units})
      : super(key: key);

  @override
  _CirclePercentIndicator createState() => _CirclePercentIndicator();
}

class _CirclePercentIndicator extends State<CirclePercentIndicator> {
  /// TODO Need to understand how to get this dynamically form DB/Iphone

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircularPercentIndicator(
        radius: MediaQuery.of(context).size.width / 3.1,
        lineWidth: MediaQuery.of(context).size.width / 20,
        animation: true,
        percent: (widget.actualValue / widget.goal >= 1)
            ? 1
            : widget.actualValue / widget.goal,
        center: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.actualValue.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .merge(TextStyle(color: widget.color)),
              ),
              (widget.units == "Steps")
                  ? Text("${widget.units}",
                      style: Theme.of(context).textTheme.caption)
                  : SizedBox.shrink()
            ],
          ),
        ),
        backgroundColor: Colors.grey,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: widget.color,
      ),
    );
  }
}
