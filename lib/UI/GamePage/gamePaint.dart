import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/globalUIElements.dart';

class GamePainter extends CustomPainter {
  //locals
  Size canvasSize;
  List<List<double>> currentPlayerPos;
  List<double> currentProjectilePos;
  List<List<double>> playerShootSetup;
  List<int> playerTeams;
  int currentPlayer;

  ///
  /// CONSTRUCTORS
  ///

  GamePainter(this.currentPlayer, this.playerTeams, this.playerShootSetup);

  ///
  /// FUNCTIONS
  ///

  Offset relativePos(double x, double y) {
    //takes x & y between 0 and 1
    //returns size based on screen
    double newX = x * canvasSize.width;
    double newY = (1 - y) * canvasSize.height;
    return Offset(newX, newY);
  }

  Offset relPos(Offset pos) {
    // takes x and y between 0 and 1
    // return size based on screen
    return Offset(pos.dx * canvasSize.width, (1 - pos.dy) * canvasSize.height);
  }

  Offset actualPos(Offset pos) {
    // takes x & y from game size and returns between 1 & 0
    return Offset(pos.dx / canvasSize.width, 1 - (pos.dy / canvasSize.height));
  }

  List<double> getPlayerAnglesArray(List<List<double>> list) {
    List<double> newList = List.empty(growable: true);
    for (int i = 0; i < list.length; i++) newList.add(list[i][1]);
    return newList;
  }

  double calcNearestHeight(List<double> terrainHeights, double relPos) {
    //return nearest index int
    double blockWidth = 1 / terrainHeights.length;
    double blockRight;
    int nearestIndex = 0;
    for (int x = 0; x < terrainHeights.length; x++) {
      blockRight = (x) * blockWidth;
      if (relPos > blockRight) {
        //located on left of block x+1
        nearestIndex = x;
      }
    }
    return terrainHeights[nearestIndex];
  }

  ///
  /// SUBROUTINES
  ///

  void drawPlayer(int colour, List<double> pos, Canvas canvas, int playerHealth,
      double angle, int player) {
    //define locals
    const double drawRadius = globals.playerRadius;
    double drawAngleRadians = angle * globals.degreesToRadians;
    Offset translate = Offset(-cos(drawAngleRadians) * drawRadius,
        -sin(drawAngleRadians) * drawRadius);
    Offset position = relPos(Offset(pos[0], pos[1]));
    Offset cannonStart = position.translate(translate.dx, translate.dy);
    Offset cannonEnd = cannonStart.translate(translate.dx, translate.dy);
    Offset turretActual = actualPos(cannonEnd);
    //define paints
    final TextPainter playerHealthText = globals.defaultTextPaint
      ..text = TextSpan(text: playerHealth.toString(), style: UI.defaultText())
      ..layout();
    final Paint playerCircle = globals.defaultDrawPaint
      ..color = globals.teamColors[colour]
      ..strokeWidth = drawRadius / 2
      ..strokeCap = StrokeCap.square;

    // set turretPos
    globals.turretPos[player] = [turretActual.dx, turretActual.dy];

    //draw paints
    canvas.drawArc(
        Rect.fromCenter(
            center: position, height: 2 * drawRadius, width: 2 * drawRadius),
        0,
        -pi,
        true,
        playerCircle);
    canvas.drawPoints(PointMode.lines, [cannonStart, cannonEnd], playerCircle);
    playerHealthText.paint(
        canvas, position.translate(-drawRadius, -drawRadius * 4));
  }

  void spawnInPlayers(
      List<int> playerColours, List<double> terrainHeights, Canvas canvas) {
    int amountOfPlayers = playerColours.length;
    double playerY = 0.0;
    double playerX = 0.0;
    //empty only on first render
    if (globals.firstRender) {
      globals.playerPos = new List.filled(amountOfPlayers, [0, 0]);
      globals.turretPos = new List.filled(amountOfPlayers, [0, 0]);
    }

    for (int players = 0; players < amountOfPlayers; players++) {
      //vars
      double playerShootAngle = getPlayerAnglesArray(playerShootSetup)[players];
      //place in player on firstRender calculate pos
      if (globals.firstRender) {
        playerX = (players + 1) / (amountOfPlayers + 1);
        playerY = calcNearestHeight(terrainHeights, playerX);
        globals.playerPos[players] = [playerX, playerY];
      }
      currentPlayerPos = globals.playerPos;
      drawPlayer(playerColours[players], globals.playerPos[players], canvas,
          globals.playerHealth[players].round(), playerShootAngle, players);
    }
  }

  void drawProjectile(int colour, List<double> pos, Canvas canvas) {
    //define vars
    Offset position = Offset(pos[0], pos[1]);
    final paint = globals.defaultDrawPaint..color = globals.teamColors[colour];

    //draw projectile
    canvas.drawCircle(relPos(position).translate(0, -3), 3, paint);
  }

  void spawnProjectile(Canvas canvas) {
    if (globals.projectilePos != null) {
      double sX = globals.projectilePos[0];
      double sY = globals.projectilePos[1];

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
      drawProjectile(currentPlayer, [sX, sY], canvas);
    }
  }

  void generateTerrain(List<double> terrainHeights, Canvas canvas) {
    int xAmount = terrainHeights.length;
    int yAmount = globals.terrainColumnsToRender;
    int red;
    int blue;
    int green;
    int minFractionFloor;
    List<Color> colors = globals.terrainColors;
    Color blockColor;
    Color colorAbove;
    Color colorBelow;
    double fractionThere;
    double actualHeight;
    double blockHeight;
    double blockTop;
    double blockWidth = 1 / xAmount;
    double blockRight;
    Offset posBL;
    Offset posTR;

    //reset terrain cache
    globals.terrainCacheLocation = List.empty(growable: true);
    globals.terrainCacheColour = List.empty(growable: true);

    //loop through columns
    for (int x = 0; x < xAmount; x++) {
      //calculate height
      actualHeight = terrainHeights[x];

      //calculate block height
      blockHeight = actualHeight / yAmount;

      //calculate row position
      blockRight = (x + 1) * blockWidth;

      //loop through rows
      for (int y = 1; y < yAmount; y++) {
        //calculate top postion
        blockTop = blockHeight * y;

        //square vertex positions
        posBL = Offset(blockRight - blockWidth, blockTop - blockHeight);
        posTR = Offset(blockRight, blockTop);
        if (y == yAmount - 1) {
          posTR = Offset(blockRight, terrainHeights[x]);
        }

        //add block blend
        posBL = posBL.translate(0, -0.05);

        //choose colour
        fractionThere = (y / yAmount) * (colors.length - 1);
        minFractionFloor = fractionThere.floor();
        colorBelow = colors[minFractionFloor];
        colorAbove = colors[minFractionFloor + 1 > colors.length - 1
            ? colors.length - 1
            : minFractionFloor + 1];
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
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.butt;
        canvas.drawRect(Rect.fromPoints(relPos(posBL), relPos(posTR)), paint);
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
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.butt;
        canvas.drawRect(
            Rect.fromPoints(relPos(globals.terrainCacheLocation[i][0]),
                relPos(globals.terrainCacheLocation[i][1])),
            paint);
      }
    }

    //place in characters
    spawnInPlayers(playerTeams, gameMap, canvas);
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
