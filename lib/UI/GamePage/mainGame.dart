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
  double zoom = globals.defaultZoom;

  //functions
  void moveScroller(double increase) {
    double currentPos = globals.gameScroller.offset;
    double newPos = currentPos + increase;
    double maxPos = UI.screenWidth(context) * zoom * 0.5;
    newPos = newPos >= 0
        ? newPos < maxPos
            ? newPos
            : maxPos
        : 0;
    print(newPos);
    globals.gameScroller.jumpTo(newPos);
  }

  void keyPresses(RawKeyEvent key) {
    String keyChar = key.data.keyLabel ?? "";
    //print("Key Press: " + keyChar);
    switch (keyChar) {
      case "a":
        //move left
        moveScroller(-globals.scrollAmount);
        break;
      case "d":
        //move right
        moveScroller(globals.scrollAmount);
        break;
    }
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      SingleChildScrollView(
        controller: globals.gameScroller,
        scrollDirection: Axis.horizontal,
        child: RawKeyboardListener(
          autofocus: true,
          onKey: keyPresses,
          focusNode: globals.gameInputs,
          child: CustomPaint(
            size:
                Size(UI.screenWidth(context) * zoom, UI.screenHeight(context)),
            painter: GamePainter(),
          ),
        ),
      ),
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
    double smoothedHeight;
    double relativeX1;
    double relativeX;
    Offset posBL;
    Offset posTR;

    //loop through columns
    for (int x = 1; x <= xAmount; x++) {
      //loop through rows
      for (int y = 1; y <= yAmount; y++) {
        //calculate the nearest mapping value to estimate height at
        relativeX = x / xAmount;
        nearestIndex = (relativeX * terrainHeights.length).floor();
        nearestIndex = nearestIndex >= terrainHeights.length
            ? terrainHeights.length - 1
            : nearestIndex;
        /*diffOfTerrain = nearestIndex == terrainHeights.length - 1
            ? 0
            : (terrainHeights[nearestIndex + 1] - terrainHeights[nearestIndex]);*/
        smoothedHeight = terrainHeights[nearestIndex];
        /*+
            (diffOfTerrain * (relativeX - nearestIndex));*/
        heightPos = y / yAmount;
        if (smoothedHeight > heightPos) {
          //square vertex positions
          relativeX = x / xAmount;
          relativeX1 = (x - 1) / xAmount;
          posBL = Offset(relativeX1, 1 - ((y - 1) / yAmount));
          posTR = Offset(relativeX, 1 - (y / yAmount));

          //choose colour
          fractionThere = (heightPos / smoothedHeight) * (colors.length - 1);
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

          //draw block
          final paint = Paint()
            ..color = blockColor
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.square;
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
    generateTerrain(globals.terrainMaps[0], canvas);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
