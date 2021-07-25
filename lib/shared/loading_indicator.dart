import 'package:flutter/material.dart';

Widget loadingIndicator() {
  return Center(
      child: Container(
    width: 100,
    height: 100,
    child: CircularProgressIndicator(),
  ));
}
