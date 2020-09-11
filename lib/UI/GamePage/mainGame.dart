import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

class MainGamePage extends StatefulWidget {
  //constructor of class
  MainGamePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainGamePageState createState() => _MainGamePageState();
}

class _MainGamePageState extends State<MainGamePage> {
  //locals

  //functions

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      CustomPaint(
        size: Size(UI.screenWidth(context),
            UI.screenHeight(context) - (2 * UI.getPaddingSize(context))),
        painter: GamePainter(),
      ),
    ], context: context);
    return page;
  }
}

class GamePainter extends CustomPainter {
  //locals
  Size canvasSize;

  Offset relativePos(double x, double y) {
    //takes x & y between 0 and 100
    //returns size based on screen
    double newX = (x / 100) * canvasSize.width;
    double newY = (y / 100) * canvasSize.height;
    return Offset(newX, newY);
  }

  void generateTerrain(List<double> terrainHeights) {
    int xAmount = globals.terrainRowsToRender;
    int yAmount = globals.terrainColumnsToRender;
    int nearestIndex;
    int red;
    int blue;
    int green;
    List<Color> colors = globals.terrainColors;
    Color blockColor;
    Color colorAbove;
    Color colorBelow;
    double heightPos;
    double fractionThere;
    Offset posBL;
    Offset posBR;
    Offset posTR;
    Offset posTL;

    //loop through columns
    for (int x = 1; x < xAmount; x++) {
      //loop through rows
      for (int y = 1; y < yAmount; y++) {
        nearestIndex = ((x / xAmount) * terrainHeights.length).round();
        heightPos = y / yAmount;
        if (terrainHeights[nearestIndex] > heightPos) {
          //square vertex positions
          posBL = Offset((x - 1) / xAmount, (y - 1) / yAmount);
          posBR = Offset((x) / xAmount, (y - 1) / yAmount);
          posTL = Offset((x) / xAmount, (y) / yAmount);
          posTR = Offset((x - 1) / xAmount, (y) / yAmount);

          //choose colour
          fractionThere = heightPos * colors.length;
          colorBelow = colors[0];
          colorAbove = colors[1];
          red = (fractionThere * (colorAbove.red - colorBelow.red)).round() +
              colorBelow.red;
          green =
              (fractionThere * (colorAbove.green - colorBelow.green)).round() +
                  colorBelow.green;
          blue = (fractionThere * (colorAbove.blue - colorBelow.blue)).round() +
              colorBelow.blue;
          blockColor = Color.fromRGBO(red, green, blue, globals.terrainOpacity);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvasSize = size;
    final pointMode = PointMode.polygon;
    final points = [
      relativePos(50, 50),
      relativePos(25, 25),
      relativePos(75, 25),
      relativePos(50, 50)
    ];
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    //render point
    canvas.drawPoints(pointMode, points, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
