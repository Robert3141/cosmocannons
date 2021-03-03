import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:draw_arrow/draw_arrow.dart';
import 'package:flutter/rendering.dart';
import 'package:cosmocannons/overrides.dart';

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
    var blockWidth = 1 / terrainHeights.length;
    var blockRight = 0.0;
    var nearestIndex = 0;
    for (var x = 0; x < terrainHeights.length; x++) {
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

  void spawnProjectile(Canvas canvas) {
    Projectile p;
    Offset start;
    Offset end;
    for (var i = 0; i < globals.projectiles.length; i++) {
      //draw projectile
      p = globals.projectiles[i];
      final paint = Paint()..color = p.teamColour;
      p.draw(canvas);

      //draw arrow if its out of range
      if (p.aX < 0) {
        if (p.aY > 1) {
          //arrow top left corner
          end = Offset(globals.rangeArrowPadding, globals.rangeArrowPadding);
          start =
              end.translate(globals.rangeArrowLength, globals.rangeArrowLength);
          canvas.drawArrow(start, end, painter: paint);
        } else {
          //arrow left side
          end = Offset(0, p.rY);
          start = end.translate(globals.rangeArrowLength, 0);
          canvas.drawArrow(start, end, painter: paint);
        }
      } else if (p.aX > 1) {
        if (p.aY > 1) {
          //arrow top right corner
          end = Offset(globals.canvasSize.width - globals.rangeArrowPadding,
              globals.rangeArrowPadding);
          start = end.translate(
              -globals.rangeArrowLength, globals.rangeArrowLength);
          canvas.drawArrow(start, end, painter: paint);
        } else {
          //arrow right side
          end = Offset(
              globals.canvasSize.width - globals.rangeArrowPadding, p.rY);
          start = end.translate(-globals.rangeArrowLength, 0);
          canvas.drawArrow(start, end, painter: paint);
        }
      } else if (p.aY > 1) {
        //arrow top
        end = Offset(p.rX, 0);
        start = end.translate(0, globals.rangeArrowLength);
        canvas.drawArrow(start, end, painter: paint);
      }
    }
  }

  List<Offset> calcPoints() {
    var playerPos = globals.players[globals.currentPlayer].aPos;
    var arrow = Offset(-(globals.arrowTop.dx - playerPos.dx),
        globals.arrowTop.dy - playerPos.dy);
    var angle = arrow.direction;
    var intensity = arrow.distance * globals.shootSF;
    var u = Offset(intensity * -cos(angle), intensity * sin(angle));
    var a = Offset(globals.Ax, globals.Ay);
    var shootProjections = List<Offset>.empty(growable: true);
    var x = 0.0;
    var y = 0.0;
    var timeSec = 0.0;

    //add positions
    for (var i = 0; i < 10; i++) {
      timeSec = i * 0.1;
      x = playerPos.dx +
          (u.dx * timeSec + 0.5 * a.dx * timeSec * timeSec) * globals.xSF;
      y = playerPos.dy +
          (u.dy * timeSec + 0.5 * a.dy * timeSec * timeSec) * globals.ySF;
      shootProjections.add(Offset(x, y));
    }
    return shootProjections;
  }

  void drawAimArrow(Canvas canvas, Player player, Offset endPos) {
    if (globals.dragGhost) {
      if (!globals.useProjection) {
        //use aim arrow
        var painter = Paint()
          ..blendMode = BlendMode.plus
          ..color = player.teamColour;
        canvas.drawArrow(player.rPos, endPos.toRelative(), painter: painter);
      } else {
        //draw projection
        var painter = Paint()
          ..blendMode = BlendMode.plus
          ..color = Colors.white38;
        var points = calcPoints();
        for (var pos in points) {
          canvas.drawCircle(pos.toRelative(), 3, painter);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    arrowTop = globals.arrowTop;
    if (globals.projectiles != null) {
      if (globals.projectiles.isNotEmpty) {
        canvas.drawCircle(
            globals.projectiles[0].rPos, 3, Paint()..color = Colors.pink);
      }
    }

    spawnProjectile(canvas);
    drawAimArrow(canvas, globals.players[globals.currentPlayer], arrowTop);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    //return arrowTop != globals.arrowTop || dragGhost != globals.dragGhost;
    //check projectiles
    var updated = false;
    for (var i = 0; i < globals.projectiles.length; i++) {
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
    if (globals.players.isNotEmpty) {
      for (var p = 0; p < globals.players.length; p++) {
        globals.players[p].draw(canvas);
      }
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
    var updated = false;
    for (var i = 0; i < globals.players.length; i++) {
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
    var xAmount = terrainHeights.length;
    var yAmount = globals.terrainColumnsToRender;
    var red = 0;
    var blue = 0;
    var green = 0;
    var minFractionFloor = 0;
    var colors = globals.terrainColors[mapNo];
    Color blockColor;
    Color colorAbove;
    Color colorBelow;
    var fractionThere = 0.0;
    var actualHeight = 0.0;
    var blockHeight = 0.0;
    var blockTop = 0.0;
    var blockWidth = 1 / xAmount;
    var blockRight = 0.0;
    Offset posBL;
    Offset posTR;

    //reset terrain cache
    globals.terrainCacheLocation = List.empty(growable: true);
    globals.terrainCacheColour = List.empty(growable: true);

    //loop through columns
    for (var x = 0; x < xAmount; x++) {
      //calculate height
      actualHeight = terrainHeights[x];

      //calculate block height
      blockHeight = actualHeight / yAmount;

      //calculate row position
      blockRight = (x + 1) * blockWidth;

      //loop through rows
      for (var y = 1; y < yAmount; y++) {
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
    var gameMap = globals.currentMap;

    //render terrain
    if (globals.firstRender || globals.terrainUpdated) {
      generateTerrain(gameMap, canvas, globals.mapNo);
    } else {
      //use dirty canvas:
      for (var i = 0; i < globals.terrainCacheLocation.length; i++) {
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
    globals.terrainUpdated = false;
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return globals.terrainUpdated;
  }
}
