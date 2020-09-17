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
        size: Size(UI.screenWidth(context), UI.screenHeight(context)),
        painter: GamePainter(),
      ),
      /*RaisedButton(
        onPressed: () {
          setState(() {
            print("Redrawn");
          });
        },
      ),*/
    ], context: context, padding: false);
    return page;
  }
}

class GamePainter extends CustomPainter {
  //locals
  Size canvasSize;

  Offset relativePos(double x, double y) {
    //takes x & y between 0 and 100
    //returns size based on screen
    double newX = x * canvasSize.width;
    double newY = y * canvasSize.height;
    return Offset(newX, newY);
  }

  Offset relPos(Offset pos) {
    return Offset(pos.dx * canvasSize.width, pos.dy * canvasSize.height);
  }

  Canvas generateTerrain(List<double> terrainHeights, Canvas canvas) {
    int xAmount = globals.terrainRowsToRender;
    int yAmount = globals.terrainColumnsToRender;
    int nearestIndex;
    int red;
    int blue;
    int green;
    int minFractionFloor;
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

    //canvas.drawColor(Colors.cyan, BlendMode.color);

    //loop through columns
    for (int x = 1; x < xAmount; x++) {
      //loop through rows
      for (int y = 1; y < yAmount; y++) {
        nearestIndex = ((x / xAmount) * terrainHeights.length).round();
        nearestIndex = nearestIndex == terrainHeights.length
            ? terrainHeights.length - 1
            : nearestIndex;
        heightPos = y / yAmount;
        if (terrainHeights[nearestIndex] > heightPos) {
          //square vertex positions
          posBL = Offset((x - 1) / xAmount, 1 - ((y - 1) / yAmount));
          //posBR = Offset((x) / xAmount, (y - 1) / yAmount);
          //posTL = Offset((x) / xAmount, (y) / yAmount);
          posTR = Offset((x) / xAmount, 1 - (y / yAmount));

          //choose colour
          fractionThere =
              (heightPos / terrainHeights[nearestIndex]) * (colors.length - 1);
          minFractionFloor = fractionThere.floor() == colors.length - 1
              ? colors.length - 2
              : fractionThere.floor();
          colorBelow = colors[minFractionFloor];
          colorAbove = colors[minFractionFloor + 1];
          red = ((fractionThere - fractionThere.floor()) *
                      (colorAbove.red - colorBelow.red))
                  .round() +
              colorBelow.red;
          green = ((fractionThere - fractionThere.floor()) *
                      (colorAbove.green - colorBelow.green))
                  .round() +
              colorBelow.green;
          blue = ((fractionThere - fractionThere.floor()) *
                      (colorAbove.blue - colorBelow.blue))
                  .round() +
              colorBelow.blue;
          blockColor = Color.fromRGBO(red, green, blue, globals.terrainOpacity);

          final paint = Paint()
            ..color = blockColor
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round;
          canvas.drawRect(Rect.fromPoints(relPos(posBL), relPos(posTR)), paint);
        }
      }
    }
    return canvas;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvasSize = size;

    //render terrain
    generateTerrain([0.47, 0.50, 0.52, 0.58, 0.67, 0.72, 0.69], canvas);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
