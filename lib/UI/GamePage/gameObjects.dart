import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'dart:async';

class GameObject {
  ///
  /// VARIABLES
  ///

  double aX; // x pos between 0 and 1 (left to right)
  double aY; // y pos between 0 and 1 (bottom to top)

  ///
  /// GETTERS
  ///

  double get rX => aX * globals.canvasSize.width;
  double get rY => (1 - aY) * globals.canvasSize.height;
  Offset get aPos => Offset(aX, aY);
  Offset get rPos => Offset(rX, rY);

  ///
  /// SETTERS
  ///

  set rX(double x) => aX = x / globals.canvasSize.width;
  set rY(double y) => aY = 1 - (y / globals.canvasSize.height);
  set aPos(Offset pos) {
    aX = pos.dx;
    aX = pos.dy;
  }

  set rPos(Offset pos) {
    rX = pos.dx;
    rY = pos.dy;
  }
}

class Player extends GameObject {
  double health;

  Player(Offset aPos);
}

class Projectile extends GameObject {
  bool updated = false;
  Offset _u;
  Offset _a;
  Offset _startPos;
  double _timeSec;
  int _player;

  Offset get aU => _u;
  Offset get aA => _a;
  Offset get aS => this.aPos;
  double get time => _timeSec;
  Offset get aStart => _startPos;
  int get playerInt => _player;
  Player get playerObj => globals.players[player];

  Projectile(Offset u, Offset a, Offset s, int player) {
    _u = u;
    _a = a;
    _startPos = s;
    _timeSec = 0;
    _player = player;

    _animateProjectile();
  }
  Projectile.radians(double intensity, double angleRadians, int player) {
    _player = player;
    _projectileRadians(intensity, angleRadians);
  }
  Projectile.degrees(double intensity, double angleDegrees, int player) {
    _player = player;
    _projectileRadians(intensity, angleDegrees * globals.degreesToRadians);
  }

  void _projectileRadians(double intensity, double angleRadians) {
    _u = Offset(intensity * -cos(angleRadians), intensity * sin(angleRadians));
    _a = Offset(globals.Ax, globals.Ay);
    aPos = playerObj.aPos;

    _animateProjectile();
  }

  Future<List<double>> _animateProjectile() {
    Timer timer;
    Duration length = Duration(milliseconds: globals.frameLengthMs);

    //run timer
    timer = Timer.periodic(length, (timer) => _renderCallback(timer));
  }

  void _renderCallback(Timer timer) {
    //set time
    bool hitPlayer;
    double terrainHeight;
    int tick = timer.tick;
    _timeSec = (globals.frameLengthMs * tick * globals.animationSpeed) / 1000;

    //set new locations
    updated = true;
    // s = ut + 0.5att
    aX = aX + (_u.dx * _timeSec + 0.5 * aX * _timeSec * _timeSec) * globals.xSF;
    aY = aY + (_u.dy * _timeSec + 0.5 * aY * _timeSec * _timeSec) * globals.ySF;

    // hit terrain?
    terrainHeight = GlobalPainter(player, playerTeams, playerShootSetup).calcNearestHeight(globals.currentMap, aX)

    //hit player?
    hitPlayer = false;
    for (int p = 0; p < amountOfPlayers; p++) {
      if (checkInRadius(aPos, playerObj.aPos, globals.blastRadius)) {

      }
    }
  }

  bool checkInRadius(
      Offset item, Offset hitbox, double hitboxRadius) {
    return item.dx > hitbox.dx - hitboxRadius &&
        item.dx < hitbox.dx + hitboxRadius &&
        item.dy > hitbox.dy - hitboxRadius &&
        item.dy < hitbox.dy + hitboxRadius;
  }
}
