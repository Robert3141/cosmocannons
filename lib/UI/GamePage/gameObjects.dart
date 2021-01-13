import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'dart:async';

class GameObject {
  // VARIABLES

  int _team;
  bool updated = false;
  double aX = 0; // x pos between 0 and 1 (left to right)
  double aY = 0; // y pos between 0 and 1 (bottom to top)

  // GETTERS

  double get rX => aX * globals.canvasSize.width;
  double get rY => (1 - aY) * globals.canvasSize.height;
  Offset get aPos => Offset(aX, aY);
  Offset get rPos => Offset(rX, rY);
  int get team => _team;
  Color get teamColour => globals.teamColors[team];

  // SETTERS

  set rX(double x) => aX = x / globals.canvasSize.width;
  set rY(double y) => aY = 1 - (y / globals.canvasSize.height);
  set aPos(Offset pos) {
    aX = pos.dx;
    aY = pos.dy;
  }

  set rPos(Offset pos) {
    rX = pos.dx;
    rY = pos.dy;
  }
}

class Player extends GameObject {
  // attributes
  double health;
  Offset _lastShot = Offset.zero;

  //getters
  Offset get lastShot => _lastShot;

  //setters

  // constructors
  Player(Offset pos, int team) {
    aPos = pos;
    _team = team;
    health = globals.defaultPlayerHealth;
  }
  Player.fromListCreated(int p, int n, int team, List<double> terrainHeights) {
    aX = (p + 1) / (n + 1);
    aY = GamePainter().calcNearestHeight(terrainHeights, aX) +
        globals.playerRadiusY;
    _team = team;
    health = globals.defaultPlayerHealth;
  }
  Player.withHealth(Offset pos, int team, double h) {
    aPos = pos;
    _team = team;
    health = h;
  }

  //methods
  void moveRight() => move(globals.movementAmount);

  void moveLeft() => move(globals.movementAmount);

  /// Positive is right
  void move(double actualAmount) {
    aX = aX + actualAmount;

    //players loop if they move out of zone
    while (aX > 1) aX -= 1;
    while (aX < 0) aX += 1;

    //set y
    aY = GlobalPainter().calcNearestHeight(globals.currentMap, aX);

    updated = true;
  }

  void draw(Canvas canvas) {
    //define locals
    double radiusX = globals.playerRadiusX.toRelativeX();
    double radiusY = (1 - globals.playerRadiusY).toRelativeY();
    Rect topOval = Rect.fromPoints(rPos.translate(-radiusX, -radiusY),
        rPos.translate(radiusX, radiusY * 0.5));
    Rect midArc = Rect.fromPoints(
        rPos.translate(-radiusX, radiusY * 1.5), rPos.translate(radiusX, 0));
    Rect bottomArc = Rect.fromPoints(rPos.translate(-radiusX, radiusY * 1.5),
        rPos.translate(radiusX, radiusY * 0.5));

    //define paints
    final TextPainter playerHealthText = globals.defaultTextPaint
      ..text = TextSpan(
          text: (this.health <= 0 ? 0 : this.health).toString(),
          style: UI.defaultText())
      ..layout();
    Paint playerPainterEmpty = Paint()
      ..color = this.teamColour
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Paint playerPainterFill = Paint()
      ..color = this.teamColour
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    //draw paints
    canvas.drawArc(topOval, pi, 2 * pi, false, playerPainterFill);
    canvas.drawArc(midArc, pi, pi, false, playerPainterEmpty);
    canvas.drawArc(bottomArc, pi, pi, false, playerPainterEmpty);
    playerHealthText.paint(
        canvas,
        this.rPos.translate(
            -playerHealthText.width / 2, -radiusY - playerHealthText.height));
  }
}

class Projectile extends GameObject {
  Offset _u;
  Offset _a;
  Offset _startPos;
  double _timeSec;
  int _player;
  Function updateUI;

  Offset get aU => _u;
  Offset get aA => _a;
  Offset get aS => this.aPos;
  double get time => _timeSec;
  Offset get aStart => _startPos;
  int get playerInt => _player;
  Player get playerObj => globals.players[playerInt];

  /*Projectile(Offset u, Offset a, Offset s, int player) {
    _u = u;
    _a = a;
    _startPos = s;
    _timeSec = 0;
    _player = player;

    _animateProjectile();
  }*/
  Projectile.radians(
      double intensity, double angleRadians, int player, Function updater) {
    _projectileRunner(intensity, angleRadians, player, updater);
  }
  Projectile.degrees(
      double intensity, double angleDegrees, int player, Function updater) {
    _projectileRunner(
        intensity, angleDegrees * globals.degreesToRadians, player, updater);
  }

  void _projectileRunner(double intensity, double angleRadians, int player,
      Function updater) async {
    //set stuff up
    updateUI = updater;
    _player = player;
    _team = playerObj.team;

    //local vars
    Offset impactPos;

    //set set u,a,s
    _u = Offset(intensity * -cos(angleRadians), intensity * sin(angleRadians));
    _u = _u.scale(0.125, 0.125);
    _a = Offset(globals.Ax, globals.Ay);
    aPos = playerObj.aPos;

    impactPos = await _animateProjectile();

    _giveDamage(impactPos);

    //destroy now
    globals.projectiles.remove(this);
    if (globals.projectiles.length == 0) {
      globals.firing = false;
      globals.popup = false;
      updateUI();
    }
  }

  void _renderCallback(Timer timer) {
    //set time
    bool hitPlayer = false;
    double terrainHeight;
    int tick = timer.tick;
    _timeSec = (globals.frameLengthMs * tick) / 1000;

    //set new locations
    updated = true;
    print("$_u $_a");
    // s = ut + 0.5att
    aX = aX +
        (_u.dx * _timeSec + 0.5 * _a.dx * _timeSec * _timeSec) * globals.xSF;
    aY = aY +
        (_u.dy * _timeSec + 0.5 * _a.dy * _timeSec * _timeSec) * globals.ySF;
    if (tick % 1 == 0) updateUI();
    // hit terrain?
    terrainHeight = GlobalPainter().calcNearestHeight(globals.currentMap, aX);

    //hit player?
    hitPlayer = false;
    for (int p = 0; p < globals.players.length; p++) {
      if (checkInRadius(aPos, globals.players[p].aPos, globals.blastRadius) &&
          globals.players[p].team != playerInt) {
        // player hit
        hitPlayer = true;
      }
    }

    //stop when done
    if (terrainHeight >= aY || hitPlayer) {
      timer.cancel();
    }
  }

  void _giveDamage(Offset position) {
    //locals
    Offset distanceInRadius;
    //check all players
    for (int i = 0; i < globals.players.length; i++) {
      //check player in team
      if (globals.players[i].team == playerObj.team) {
        // check player in blast radius
        if (checkInRadius(
            position, globals.players[i].aPos, globals.blastRadius)) {
          //distance in radius
          distanceInRadius = globals.players[i].aPos - position;
          globals.players[i].health -=
              (globals.blastDamage * distanceInRadius.distance) /
                  globals.blastRadius;
          // TODO: check health goes to 0
        }
      }
    }
  }

  bool checkInRadius(Offset item, Offset hitbox, double hitboxRadius) {
    return item.dx > hitbox.dx - hitboxRadius &&
        item.dx < hitbox.dx + hitboxRadius &&
        item.dy > hitbox.dy - hitboxRadius &&
        item.dy < hitbox.dy + hitboxRadius;
  }

  Future<Offset> _animateProjectile() async {
    globals.firing = true;
    const Duration length = Duration(milliseconds: globals.frameLengthMs);
    const Duration check = Duration(milliseconds: globals.checkDoneMs);
    Timer timer;

    //run timer
    _timeSec = 0;
    aPos = playerObj.aPos;
    timer = Timer.periodic(length, (timer) => _renderCallback(timer));

    // wait until flight over or long flight
    while (timer.isActive && _timeSec <= globals.maxFlightLength) {
      await Future.delayed(check);
    }

    //cancel ticker and remove from UI
    timer.cancel();
    return rPos;
  }
}