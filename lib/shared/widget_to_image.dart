import 'package:flutter/material.dart';

class CardToImage extends StatefulWidget {
  final Function(GlobalKey globalKey) builder;

  const CardToImage({Key key, this.builder}) : super(key: key);

  @override
  _CardToImageState createState() => _CardToImageState();
}

class _CardToImageState extends State<CardToImage> {
  final globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: globalKey, child: widget.builder(globalKey));
  }
}
