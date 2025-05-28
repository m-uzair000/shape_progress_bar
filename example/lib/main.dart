import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shape_progress_bar/shape_progress_bar.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner:false,home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Shape Animations",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child:
        SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
              ),
              RectangleBar(
                width: 150,
                height: 150,
                duration: Duration(seconds: 3),
                borderColor: Colors.white,
                borderWidth: 10,
                startCorner: BorderCorner.topRight,
                borderRadius: 10,
                loop: true,
                useGradient: true,
                gradientColors: [Colors.cyan, Colors.purple],
                glowColor: Colors.orange,
                child: Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TriangleBar(
                size: 200,
                borderWidth: 10,
                glowWidth: 10,
                duration: const Duration(seconds: 3),
                corner: 1,
                borderColor: Colors.white,
                glowColor: Colors.orange,
                useGradient: true,
                gradientColors: [Colors.cyan, Colors.purple],
                value: null,
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              StarBar(
                size: 200,
                borderWidth: 10,
                glowWidth: 10,
                duration: const Duration(seconds: 3),
                corner: 1,
                borderColor: Colors.white,
                glowColor: Colors.orange,
                useGradient: true,
                gradientColors: [Colors.cyan, Colors.purple],
                points: 4,
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              StarBar(
                size: 200,
                borderWidth: 10,
                glowWidth: 10,
                duration: const Duration(seconds: 3),
                corner: 1,
                borderColor: Colors.white,
                glowColor: Colors.orange,
                useGradient: true,
                gradientColors: [Colors.cyan, Colors.purple],
                points: 5,
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              HeartBar(
                width: 200,
                height: 200,
                borderColor: Colors.grey,
                glowColor: Colors.red,
                borderWidth: 10,
                glowWidth: 10,
                duration: Duration(seconds: 3),
                loop: true,
                useGradient: true,
                gradientColors: [Colors.red, Colors.pink, Colors.purple],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              OvalBar(
                width: 250,
                height: 150,
                borderColor: Colors.grey.shade600,
                glowColor: Colors.blueAccent,
                borderWidth: 10,
                glowWidth: 10,
                duration: Duration(seconds: 3),
                loop: true,
                useGradient: true,
                gradientColors: [Colors.blue, Colors.green, Colors.red],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              OvalBar(
                width: 150,
                height: 250,
                borderColor: Colors.grey.shade600,
                glowColor: Colors.blueAccent,
                borderWidth: 10,
                glowWidth: 10,
                duration: Duration(seconds: 6),
                loop: true,
                useGradient: true,
                gradientColors: [Colors.blue, Colors.green, Colors.red],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ParabolaBar(
                width: 300,
                height: 150,
                borderColor: Colors.grey.shade600,
                glowColor: Colors.orange,
                borderWidth: 10,
                glowWidth: 10,
                loop: true,
                duration: Duration(seconds: 3),
                useGradient: true,
                gradientColors: [Colors.orange, Colors.yellow, Colors.red],
                inverted: false,
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ParabolaBar(
                width: 300,
                height: 150,
                borderColor: Colors.grey.shade600,
                glowColor: Colors.orange,
                borderWidth: 10,
                glowWidth: 10,
                loop: true,
                duration: Duration(seconds: 4),
                useGradient: true,
                gradientColors: [Colors.orange, Colors.yellow, Colors.red],
                inverted: true,
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              DiamondBar(
                size: 200,
                borderColor: Colors.grey.shade600,
                glowColor: Colors.orange,
                borderWidth: 10,
                glowWidth: 10,
                loop: true,
                duration: Duration(seconds: 3),
                useGradient: true,
                gradientColors: [Colors.orange, Colors.yellow, Colors.red],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              PentagonBar(
                size: 200,
                loop: true,
                borderWidth: 10,
                glowWidth: 10,
                duration: Duration(seconds: 3),
                borderColor: Colors.white,
                glowColor: Colors.orangeAccent,
                useGradient: true,
                gradientColors: [Colors.blue, Colors.purple],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              PolygonBar(
                size: 200,
                points: 6,
                // Hexagon
                loop: true,
                borderWidth: 10,
                glowWidth: 10,
                borderColor: Colors.white,
                glowColor: Colors.greenAccent,
                useGradient: true,
                gradientColors: [Colors.blue, Colors.purple],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 40),
              PolygonBar(
                size: 200,
                points: 10,
                // Hexagon
                loop: true,
                borderWidth: 10,
                glowWidth: 10,
                borderColor: Colors.white,
                glowColor: Colors.greenAccent,
                useGradient: true,
                gradientColors: [Colors.blue, Colors.purple],
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              ArrowBar(
                width: 250,
                height: 70,
                duration: Duration(seconds: 3),
                backgroundColor: Colors.grey.shade300,
                progressColor: Colors.blue,
                useGradient: true,
                gradientColors: [Colors.teal, Colors.lime],
              )
            ],
          ),
        ),
      ),
    );
  }
}
