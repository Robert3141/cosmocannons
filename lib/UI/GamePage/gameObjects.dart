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
  Function updateUI;
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
  bool drawHitbox = false;
  double health = globals.defaultPlayerHealth;
  Offset _lastShot = Offset.zero;

  //getters
  Offset get lastShot => _lastShot;

  //setters

  // constructors
  Player(Offset pos, int team, Function updater) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = globals.defaultPlayerHealth;
  }
  Player.fromListCreated(
      int p, int n, int team, List<double> terrainHeights, Function updater) {
    updateUI = updater;
    aX = (p + 1) / (n + 1);
    aY = GamePainter().calcNearestHeight(terrainHeights, aX) +
        globals.playerRadiusY;
    _team = team;
    health = globals.defaultPlayerHealth;
  }
  Player.withHealth(Offset pos, int team, double h, Function updater) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = h;
  }

  //methods
  void moveRight() => move(globals.movementAmount);

  void moveLeft() => move(-globals.movementAmount);

  /// Positive is right
  void move(double actualAmount) {
    aX = aX + actualAmount;

    //players loop if they move out of zone
    while (aX > 1) aX -= 1;
    while (aX < 0) aX += 1;

    //set y
    aY = GlobalPainter().calcNearestHeight(globals.currentMap, aX) +
        globals.playerRadiusY;

    updated = true;
    updateUI();
  }

  void draw(Canvas canvas) {
    //define locals
    double radiusX = globals.playerRadiusX.toRelativeX();
    double radiusY = (1 - globals.playerRadiusY).toRelativeY();
    double windowWidth = radiusX / 4;
    Rect topOval = Rect.fromPoints(rPos.translate(-radiusX, -radiusY),
        rPos.translate(radiusX, radiusY * 0.5));
    Rect midArc = Rect.fromPoints(rPos.translate(-radiusX, radiusY * 2.5),
        rPos.translate(radiusX, -radiusY * 0.5));
    Rect bottomArc = Rect.fromPoints(
        rPos.translate(-radiusX * 0.7, radiusY * 0.4),
        rPos.translate(radiusX * 0.7, radiusY * 1.6));

    //define paints
    final TextPainter playerHealthText = globals.defaultTextPaint
      ..text = TextSpan(
          text: (this.health <= 0 ? 0 : this.health).toString(),
          style: UI.defaultText())
      ..layout();
    Paint playerFill = Paint()
      ..color = this.teamColour
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    Paint whiteFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    Paint whiteEmpty = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Paint blackFill = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    //draw ship
    canvas.drawArc(topOval, 0, 2 * pi, false, playerFill);
    canvas.drawArc(midArc, pi, pi, false, playerFill);
    canvas.drawArc(bottomArc, pi, pi, false, blackFill);
    //draw windows
    canvas.drawCircle(rPos, windowWidth, whiteFill);
    canvas.drawCircle(rPos.translate(0, -radiusY / 3), windowWidth, whiteFill);
    canvas.drawCircle(
        rPos.translate(0, -2 * radiusY / 3), windowWidth, whiteFill);
    //draw hitbox
    if (drawHitbox)
      canvas.drawRect(
          Rect.fromCenter(
              center: rPos, width: radiusX * 2, height: radiusY * 2),
          whiteEmpty);
    //draw text
    playerHealthText.paint(
        canvas,
        this.rPos.translate(
            -playerHealthText.width / 2, -radiusY - playerHealthText.height));
  }

  @override
  String toString() {
    return "Player(health:$health, team:$team, pos:$aPos)";
  }
}

class Projectile extends GameObject {
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
  Player get playerObj => globals.players[playerInt];

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
    _u = _u.scale(globals.shootScaling, globals.shootScaling);
    _a = Offset(globals.Ax, globals.Ay);
    aPos = playerObj.aPos;

    impactPos = await _animateProjectile();

    _giveDamage(impactPos);
    _nextPlayer();

    //destroy now
    globals.projectiles.remove(this);
    if (globals.projectiles.length >= 0) {
      globals.firing = false;
      globals.popup = false;
    }
    updateUI();
  }

  void _renderCallback(Timer timer) {
    //set time
    bool hitPlayer = false;
    double terrainHeight;
    int tick = timer.tick;
    _timeSec = (globals.frameLengthMs * tick) / 1000;

    //set new locations
    updated = true;
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
      if (globals.players[p].team != playerInt) {
        if (checkInRadius(aPos, globals.players[p].aPos, globals.playerRadiusX,
            globals.playerRadiusY)) {
          // player hit
          hitPlayer = true;
          p = globals.players.length;
        }
      }
    }

    //stop when done
    if (terrainHeight >= aY || hitPlayer) {
      timer.cancel();
    }
  }

  void _giveDamage(Offset position) {
    //locals

    //check all players
    for (int i = 0; i < globals.players.length; i++) {
      //check player not in team
      if (globals.players[i].team != playerInt) {
        // check player in blast radius
        if (checkInRadius(position, globals.players[i].aPos,
            globals.playerRadiusX, globals.playerRadiusY)) {
          //player in blast radius administer damage
          globals.players[i].health -= globals.blastDamage;
          globals.players[i].updated = true;

          //remove dead players
          if (globals.players[i].health <= 0) {
            globals.players.removeAt(i);
            i--;
          }
        }
      }
    }
    updateUI();
  }

  bool checkInRadius(
      Offset item, Offset hitbox, double hitboxX, double hitBoxY) {
    return item.dx > hitbox.dx - hitboxX &&
        item.dx < hitbox.dx + hitboxX &&
        item.dy > hitbox.dy - hitBoxY &&
        item.dy < hitbox.dy + hitBoxY;
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
    return aPos;
  }

  void _nextPlayer() {
    //next player
    globals.currentPlayer++;
    if (globals.currentPlayer >= globals.players.length)
      globals.currentPlayer = 0;
    print(globals.currentPlayer);
    if (globals.type.showPlayerUI(globals.currentPlayer))
      globals.thisPlayer = globals.currentPlayer;
  }
}
