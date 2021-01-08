import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:draw_arrow/draw_arrow.dart';

extension OffsetExtender on Offset {
  /// Take values between 0 and 1 and convert to between 0 and globals.canvasSize
  Offset toRelative() {
    double newX = this.dx * globals.canvasSize.width;
    double newY = (1 - this.dy) * globals.canvasSize.height;
    return Offset(newX, newY);
  }

  /// Take values between 0 and globals.canvasSize and convert to between 0 and 1
  Offset toActual() {
    double newX = this.dx / globals.canvasSize.width;
    double newY = 1 - (this.dy / globals.canvasSize.height);
    return Offset(newX, newY);
  }
}

class GlobalPainter extends CustomPainter {
  //locals
  Size canvasSize;
  List<List<double>> currentPlayerPos;
  List<double> currentProjectilePos;

  ///
  /// CONSTRUCTORS
  ///

  GlobalPainter();

  ///
  /// FUNCTIONS
  ///

  /*Offset relativePos(double x, double y) {
    //takes x & y between 0 and 1
    //returns size based on screen
    double newX = x * canvasSize.width;
    double newY = (1 - y) * canvasSize.height;
    return Offset(newX, newY);
  }

  Offset relPos(Offset pos, [Size size]) {
    canvasSize = size ?? canvasSize;
    // takes x and y between 0 and 1
    // return size based on screen
    return Offset(pos.dx * canvasSize.width, (1 - pos.dy) * canvasSize.height);
  }

  Offset actualPos(Offset pos, [Size size]) {
    canvasSize = size ?? canvasSize;
    // takes x & y from game size and returns between 1 & 0
    return Offset(pos.dx / canvasSize.width, 1 - (pos.dy / canvasSize.height));
  }*/

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
  /// BUILD
  ///

  @override
  void paint(Canvas canvas, Size size) {
    canvasSize = size;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ShootPainter extends GlobalPainter {
  //locals
  int currentPlayer;
  List<int> playerTeams;
  List<List<double>> currentPlayerPos;
  Offset arrowTop;
  bool dragGhost;

  ShootPainter();

  void drawProjectile(Projectile projectile, Canvas canvas) {
    //define vars
    final paint = globals.defaultDrawPaint..color = projectile.teamColour;

    //draw projectile
    canvas.drawCircle(projectile.rPos, 3, paint);
  }

  void spawnProjectile(Canvas canvas) {
    Projectile p;
    Offset start;
    Offset end;
    for (int i = 0; i < globals.projectiles.length; i++) {
      //draw projectile
      p = globals.projectiles[i];
      final paint = globals.defaultDrawPaint..color = p.teamColour;
      drawProjectile(p, canvas);

      //draw arrow if its out of range
      if (p.aX < 0) {
        if (p.aY > 1) {
          //arrow top left corner
          start =
              Offset(1 - globals.rangeArrowStart, 1 - globals.rangeArrowStart)
                  .toRelative();
          end = Offset(1 - globals.rangeArrowEnd, 1 - globals.rangeArrowEnd)
              .toRelative();
          canvas.drawArrow(start, end, painter: paint);
        } else {
          //arrow left side
          start = Offset(1 - globals.rangeArrowStart, p.aY).toRelative();
          end = Offset(1 - globals.rangeArrowEnd, p.aY).toRelative();
          canvas.drawArrow(start, end, painter: paint);
        }
      } else if (p.aX > 1) {
        if (p.aY > 1) {
          //arrow top right corner
        } else {
          //arrow right side
          start = Offset(globals.rangeArrowStart, p.aY).toRelative();
          end = Offset(globals.rangeArrowEnd, p.aY).toRelative();
          canvas.drawArrow(start, end, painter: paint);
        }
      } else if (p.aY > 1) {
        //arrow top
        start = Offset(p.aX, globals.rangeArrowStart).toRelative();
        end = Offset(p.aX, globals.rangeArrowEnd).toRelative();
        canvas.drawArrow(start, end, painter: paint);
      }
    }
    }
  }

  void drawAimArrow(Canvas canvas, Offset endPos) {
    Paint painter = Paint()
      ..blendMode = BlendMode.plus
      ..color = globals.teamColors[playerTeams[currentPlayer]];
    if (dragGhost) {
      List<double> playerPos = currentPlayerPos[currentPlayer];
      canvas.drawArrow(
          relPos(Offset(playerPos[0], playerPos[1])), relPos(endPos),
          painter: painter);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    arrowTop = globals.arrowTop;
    dragGhost = globals.dragGhost;
    currentPlayerPos = globals.playerPos;

    spawnProjectile(canvas);
    drawAimArrow(canvas, arrowTop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return arrowTop != globals.arrowTop || dragGhost != globals.dragGhost;
  }
}

class CharacterPainter extends GlobalPainter {
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

  CharacterPainter();

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
      ..text = TextSpan(
          text: (playerHealth <= 0 ? 0 : playerHealth).toString(),
          style: UI.defaultText())
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
      drawPlayer(playerColours[players], globals.playerPos[players], canvas,
          globals.playerHealth[players].round(), playerShootAngle, players);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    List<double> gameMap = globals.currentMap;
    currentPlayerPos = globals.playerPos;

    spawnInPlayers(playerTeams, gameMap, canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return currentPlayerPos != globals.playerPos ||
        currentProjectilePos != globals.projectilePos;
  }
}

class GamePainter extends GlobalPainter {
  ///
  /// CONSTRUCTORS
  ///

  GamePainter();

  ///
  /// FUNCTIONS
  ///

  ///
  /// SUBROUTINES
  ///

  void generateTerrain(List<double> terrainHeights, Canvas canvas, int mapNo) {
    int xAmount = terrainHeights.length;
    int yAmount = globals.terrainColumnsToRender;
    int red;
    int blue;
    int green;
    int minFractionFloor;
    List<Color> colors = globals.terrainColors[mapNo];
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
    super.paint(canvas, size);
    List<double> gameMap = globals.currentMap;

    //render terrain
    if (globals.firstRender) {
      generateTerrain(gameMap, canvas, globals.mapNo);
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
