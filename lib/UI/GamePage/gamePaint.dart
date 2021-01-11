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

  bool checkInRadius(Offset hitbox, double hitboxRadius) {
    Offset item = this;
    return item.dx > hitbox.dx - hitboxRadius &&
        item.dx < hitbox.dx + hitboxRadius &&
        item.dy > hitbox.dy - hitboxRadius &&
        item.dy < hitbox.dy + hitboxRadius;
  }
}

class GlobalPainter extends CustomPainter {
  //locals

  ///
  /// CONSTRUCTORS
  ///

  GlobalPainter();

  ///
  /// FUNCTIONS
  ///

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
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ShootPainter extends GlobalPainter {
  //locals
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

  void drawAimArrow(Canvas canvas, Player player, Offset endPos) {
    Paint painter = Paint()
      ..blendMode = BlendMode.plus
      ..color = player.teamColour;
    if (globals.dragGhost) {
      canvas.drawArrow(player.rPosCentre, endPos.toRelative(),
          painter: painter);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    arrowTop = globals.arrowTop;

    spawnProjectile(canvas);
    drawAimArrow(canvas, globals.players[globals.currentPlayer], arrowTop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //return arrowTop != globals.arrowTop || dragGhost != globals.dragGhost;
    //check projectiles
    bool updated = false;
    for (int i = 0; i < globals.projectiles.length; i++) {
      updated |= globals.projectiles[i].updated;
    }
    //check arrow
    updated |= arrowTop != globals.arrowTop;
    return updated;
  }
}

class CharacterPainter extends GlobalPainter {
  //locals

  ///
  /// CONSTRUCTORS
  ///

  CharacterPainter();

  ///
  /// SUBROUTINES
  ///

  void spawnInPlayers(List<double> terrainHeights, Canvas canvas) {
    if (globals.players.isNotEmpty)
      for (int p = 0; p < globals.players.length; p++) {
        globals.players[p].draw(canvas);
      }
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    spawnInPlayers(globals.currentMap, canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //check all players
    bool updated = false;
    for (int i = 0; i < globals.players.length; i++) {
      updated |= globals.players[i].updated;
    }
    return updated;
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
        canvas.drawRect(
            Rect.fromPoints(posBL.toRelative(), posTR.toRelative()), paint);
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
            Rect.fromPoints(globals.terrainCacheLocation[i][0].toRelative(),
                globals.terrainCacheLocation[i][1].toRelative()),
            paint);
      }
    }

    //place in characters
    globals.firstRender = false;
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    //TODO: FIX THIS
    return false;
  }
}
