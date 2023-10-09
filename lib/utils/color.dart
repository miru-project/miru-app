import 'package:flutter/material.dart';

class ColorUtils {
  static Color getColorByText(String text) {
    final int colorIndex = text.length % 10;
    final color = [
      Colors.blueGrey[500],
      Colors.brown[500],
      Colors.deepPurple[500],
      Colors.green[500],
      Colors.indigo[500],
      Colors.lightBlue[500],
      Colors.lightGreen[500],
      Colors.orange[500],
      Colors.pink[500],
      Colors.purple[500],
      Colors.red[500],
      Colors.teal[500],
    ][colorIndex];
    return color!;
  }
}
