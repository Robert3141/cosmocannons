import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;

class GamePainter extends CustomPainter {
  //locals
  Size canvasSize;
  List<List<double>> currentPlayerPos;
  List<double> currentProjectilePos;

  Offset relativePos(double x, double y) {
    //takes x & y between 0 and 100
    //returns size based on screen
    double newX = x * canvasSize.width;
    double newY = y * canvasSize.height;
    return Offset(newX, newY);
  }

  Offset relPos(Offset pos) {
    // takes x and y between 0 and 1
    // return size based on screen
    return Offset(pos.dx * canvasSize.width, pos.dy * canvasSize.height);
  }

  void drawPlayer(int colour, List<double> pos, Canvas canvas) {
    Offset position = Offset(pos[0], pos[1]);
    final paint = Paint()
      ..color = globals.teamColors[colour]
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    canvas.drawCircle(relPos(position), 10, paint);
  }

  void spawnInPlayers(
      List<int> playerColours, List<double> terrainHeights, Canvas canvas) {
    int amountOfPlayers = playerColours.length;
    double playerY = 0.0;
    double playerX = 0.0;
    //empty only on first render
    if (globals.firstRender) {
      globals.playerPos = new List.filled(amountOfPlayers, [0, 0]);
    }

    for (int players = 0; players < amountOfPlayers; players++) {
      //place in player on firstRender calculate pos
      if (globals.firstRender) {
        playerX = (players + 1) / (amountOfPlayers + 1);
        playerY = calcNearestHeight(terrainHeights, playerX);
        globals.playerPos[players] = [playerX, 1 - playerY];
      }
      currentPlayerPos = globals.playerPos;
      drawPlayer(playerColours[players], globals.playerPos[players], canvas);
    }
  }

  void drawProjectile(int colour, List<double> pos, Canvas canvas) {
    Offset position = Offset(pos[0], pos[1]);
    print(position);
    final paint = Paint()
      ..color = globals.teamColors[colour]
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    canvas.drawCircle(relPos(position), 3, paint);
  }

  void spawnProjectile(Canvas canvas) {
    if (globals.projectilePos != null) {
      double sX = globals.projectilePos[0];
      double sY = globals.projectilePos[1];

      //add current player pos
      //sX = sX + currentPlayerPos[]

      // make between 1 & 0
      sX = sX > 1
          ? 1
          : sX < 0
              ? 0
              : sX;
      sY = sY > 1
          ? 1
          : sY < 0
              ? 0
              : sY;
      drawProjectile(1, [sX, sY], canvas);
    }
  }

  double calcNearestHeight(List<double> terrainHeights, double relPos) {
    //return nearest index int
    int nearestIndex = (relPos * terrainHeights.length).floor();
    nearestIndex = nearestIndex >= terrainHeights.length
        ? terrainHeights.length - 1
        : nearestIndex;
    return terrainHeights[nearestIndex];
  }

  void generateTerrain(List<double> terrainHeights, Canvas canvas) {
    int xAmount = globals.terrainRowsToRender;
    int yAmount = globals.terrainColumnsToRender;
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

    //reset terrain cache
    globals.terrainCacheLocation = List.empty(growable: true);
    globals.terrainCacheColour = List.empty(growable: true);

    //loop through columns
    for (int x = 1; x <= xAmount; x++) {
      //loop through rows
      for (int y = 1; y <= yAmount; y++) {
        //calculate the nearest mapping value to estimate height at
        relativeX = x / xAmount;
        smoothedHeight = calcNearestHeight(terrainHeights, relativeX);
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
          globals.terrainCacheLocation.add([posBL, posTR]);
          globals.terrainCacheColour.add(blockColor);
          final paint = Paint()
            ..color = blockColor
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.square;
          canvas.drawRect(Rect.fromPoints(relPos(posBL), relPos(posTR)), paint);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvasSize = size;
    List<double> gameMap = globals.terrainMaps[0];

    //render terrain
    if (globals.firstRender) {
      generateTerrain(gameMap, canvas);
    } else {
      //use dirty canvas:
      for (int i = 0; i < globals.terrainCacheLocation.length; i++) {
        final paint = Paint()
          ..color = globals.terrainCacheColour[i]
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.square;
        canvas.drawRect(
            Rect.fromPoints(relPos(globals.terrainCacheLocation[i][0]),
                relPos(globals.terrainCacheLocation[i][1])),
            paint);
      }
    }

    //place in characters
    spawnInPlayers(globals.playerTeams, gameMap, canvas);
    spawnProjectile(canvas);
    globals.firstRender = false;
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    if (currentPlayerPos == globals.playerPos &&
        currentProjectilePos == globals.projectilePos) {
      return false;
    } else {
      return true;
    }
  }
}
