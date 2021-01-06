import 'dart:math';
import 'dart:ui';
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
  Offset _u;
  Offset _a;
  Offset _startPos;
  double _timeSec;

  Offset get aU => _u;
  Offset get aA => _a;
  Offset get aS => this.aPos;
  double get time => _timeSec;
  Offset get aStart => _startPos;

  Projectile(Offset u, Offset a, Offset s) {
    _u = u;
    _a = a;
    _startPos = s;
    _timeSec = 0;

    _animateProjectile();
  }
  Projectile.radians(double intensity, double angleRadians, int player) {
    _projectileRadians(intensity, angleRadians, player);
  }
  Projectile.degrees(double intensity, double angleDegrees, int player) {
    _projectileRadians(
        intensity, angleDegrees * globals.degreesToRadians, player);
  }

  void _projectileRadians(double intensity, double angleRadians, int player) {
    _u = Offset(intensity * -cos(angleRadians), intensity * sin(angleRadians));
    _a = Offset(globals.Ax, globals.Ay);
    aPos = globals.players[player].aPos;

    _animateProjectile();
  }

  Future<List<double>> _animateProjectile() {
    Ticker timer;
    Duration length = Duration(milliseconds: globals.frameLengthMs);

    //run timer
    timer = Timer.periodic(length,renderCallback(Timer timer));
  }

  void renderCallback(Timer timer) {}
}
