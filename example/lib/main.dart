import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shape_progress_bar/shape_progress_bar.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: RectangleBox(
          width: 150,
          height: 150,
          duration: Duration(seconds: 10),
          borderColor: Colors.white,
          borderWidth: 12,
          startCorner: BorderCorner.topRight,
          borderRadius: 12,
          loop: true,
          useGradient: true,
          gradientColors: [Colors.cyan, Colors.purple],
          glowColor: Colors.orange,
          child: Center(
            child: Text(
              "Playing...",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
      ),
    ),
  ));
}