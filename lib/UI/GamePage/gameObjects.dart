import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'dart:async';
import 'package:cosmocannons/overrides.dart';

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

  void draw(Canvas canvas) {
    //define vars
    final paint = Paint()..color = teamColour;

    //draw projectile
    canvas.drawCircle(rPos, 3, paint);
  }
}

class Player extends GameObject {
  // attributes
  bool drawHitbox = false;
  double health = globals.defaultPlayerHealth;
  Offset _lastShot = Offset.zero;
  BuildContext _context;

  //getters
  Offset get lastShot => _lastShot;

  //setters

  // constructors
  Player(Offset pos, int team, Function updater, BuildContext context) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = globals.defaultPlayerHealth;
    _context = context;
  }
  Player.fromListCreated(int p, int n, int team, List<double> terrainHeights,
      Function updater, BuildContext context) {
    updateUI = updater;
    aX = (p + 1) / (n + 1);
    aY = GamePainter().calcNearestHeight(terrainHeights, aX) +
        globals.playerRadiusY;
    _team = team;
    health = globals.defaultPlayerHealth;
    _context = context;
  }
  Player.withHealth(
      Offset pos, int team, double h, Function updater, BuildContext context) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = h;
    _context = context;
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

  /// Randomly picks a player not on it's team unless given specific team.
  /// Accuracy is given between 0 (very innacurate) and 1 (very accurate)
  void playAI(Function updater, int thisPlayer,
      {int teamToTarget, double accuracy}) async {
    //local vars
    double timeSec = 2;
    const Offset a = Offset(globals.Ax, globals.Ay);
    double angleVariance;
    double uX = 0;
    double uY = 0;
    int selectedPlayer =
        _selectPlayer(teamToTarget, globals.players[thisPlayer].team);
    Offset u;
    Offset s;
    Random rand = Random();

    //choose to move
    if (rand.nextInt(10) > 6) rand.nextBool() ? moveLeft() : moveRight();
    await Future.delayed(Duration(milliseconds: 500));

    //calculates optimum trajectory for hit
    // u = (s-0.5*a*t*t) / t
    s = globals.players[selectedPlayer].aPos - aPos;
    s = s.scale(1 / globals.xSF, 1 / globals.ySF);
    timeSec = rand.nextDouble() * 1.5 + 0.5;
    uX = (s.dx - (0.5 * a.dx * timeSec * timeSec)) / timeSec;
    uY = (s.dy - (0.5 * a.dy * timeSec * timeSec)) / timeSec;
    u = Offset(uX, uY);

    // adds variability to firing angle
    angleVariance = accuracy ?? 1 - (rand.nextDouble() / 8);
    angleVariance = rand.nextBool() ? 2 - angleVariance : angleVariance;
    u = Offset(u.dx * angleVariance, u.dy);

    //fire projectile
    globals.projectiles.add(Projectile.velocity(u, thisPlayer, updater));
  }

  @override
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

  int _selectPlayer(int teamToTarget, int playerTeam) {
    //locals
    List<int> playersToChoose = List<int>.empty(growable: true);
    Random rand = new Random();

    // add players to target list
    if (teamToTarget != null &&
        teamToTarget != playerTeam &&
        globals.players.any((element) => element.team == teamToTarget)) {
      //teamToTarget exists in array
      for (int i = 0; i < globals.players.length; i++) {
        if (globals.players[i].team == teamToTarget) playersToChoose.add(i);
      }
    } else {
      //select random player not on team
      for (int i = 0; i < globals.players.length; i++) {
        if (globals.players[i].team != playerTeam) playersToChoose.add(i);
      }
    }

    //chose random number
    return playersToChoose[rand.nextInt(playersToChoose.length)];
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

  Projectile.velocity(Offset velocity, int player, Function updater) {
    _projectileRunner(velocity, player, updater);
  }
  Projectile.radians(
      double intensity, double angleRadians, int player, Function updater) {
    _projectileRunner(angleToOffset(intensity, angleRadians), player, updater);
  }
  Projectile.degrees(
      double intensity, double angleDegrees, int player, Function updater) {
    _projectileRunner(
        angleToOffset(intensity, angleDegrees * globals.degreesToRadians),
        player,
        updater);
  }

  Offset angleToOffset(double intensity, double angleRadians) {
    return Offset(
        intensity * -cos(angleRadians), intensity * sin(angleRadians));
  }

  void _projectileRunner(Offset velocity, int player, Function updater) async {
    //share firing of projectile // TODO finish the sending of packets and receiving of data
    if (globals.type == globals.GameType.multiHost) ;
    if (globals.type == globals.GameType.multiClient) ;

    //set stuff up
    updateUI = updater;
    _player = player;
    _team = playerObj.team;

    //local vars
    Offset impactPos;

    //set set u,a,s
    _u = velocity;
    _a = Offset(globals.Ax, globals.Ay);
    aPos = playerObj.aPos;

    impactPos = await _animateProjectile();

    _giveDamage(impactPos);
    _nextPlayer();
    _checkWinner(playerObj._context);

    //destroy now
    globals.projectiles.remove(this);
    if (globals.projectiles.length >= 0) {
      globals.firing = false;
      globals.popup = false;
    }
    updateUI();

    //singleplayer run AI
    if (globals.thisPlayer != globals.currentPlayer &&
        globals.type == globals.GameType.singlePlayer)
      globals.players[globals.currentPlayer]
          .playAI(updater, globals.currentPlayer);
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

  void _renderCallback(Timer timer) {
    //set time
    bool hitPlayer = false;
    double terrainHeight;
    int tick = timer.tick;
    _timeSec = (globals.frameLengthMs * tick) / 1000;

    //set new locations
    updated = true;
    // s = ut + 0.5att
    aX = playerObj.aX +
        (_u.dx * _timeSec + 0.5 * _a.dx * _timeSec * _timeSec) * globals.xSF;
    aY = playerObj.aY +
        (_u.dy * _timeSec + 0.5 * _a.dy * _timeSec * _timeSec) * globals.ySF;
    if (tick % 1 == 0) updateUI();
    // hit terrain?
    terrainHeight = GlobalPainter().calcNearestHeight(globals.currentMap, aX);

    //hit player?
    hitPlayer = false;
    for (int p = 0; p < globals.players.length; p++) {
      if (globals.players[p].team != playerObj.team) {
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

  bool checkInRadius(
      Offset item, Offset hitbox, double hitboxX, double hitBoxY) {
    return item.dx > hitbox.dx - hitboxX &&
        item.dx < hitbox.dx + hitboxX &&
        item.dy > hitbox.dy - hitBoxY &&
        item.dy < hitbox.dy + hitBoxY;
  }

  void _nextPlayer() {
    //next player
    globals.currentPlayer++;
    if (globals.currentPlayer >= globals.players.length)
      globals.currentPlayer = 0;
    if (globals.type.showPlayerUI(globals.currentPlayer))
      globals.thisPlayer = globals.currentPlayer;
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
            //if player killed is below the current player then the current player needs updating
            if (i < globals.currentPlayer) {
              globals.currentPlayer--;
              _player--;
            }

            //count from after the player removed
            i--;
          }
        }
      }
    }
    updateUI();
  }

  void _checkWinner(BuildContext context) {
    if (globals.players.isEmpty) {
      //Players wiped each other out
    } else {
      //check amount of teams in play
      List<int> teamsLeft = List<int>.empty(growable: true);
      int playersTeam;

      for (int p = 0; p < globals.players.length; p++) {
        playersTeam = globals.players[p].team;
        //team not in list
        if (teamsLeft.lastIndexOf(playersTeam) == -1)
          teamsLeft.add(playersTeam);
      }

      if (teamsLeft.length == 1) {
        // last team wins
        UI.dataInputPopup(context, [null],
            notInput: true,
            data: ["Team ${globals.defaultTeamNames[teamsLeft[0]]} has won!"],
            onFinish: (bool b) {
          UI.startNewPage(context, [], newPage: LauncherPage());
        });
        updateUI();
      }
    }
  }
}
