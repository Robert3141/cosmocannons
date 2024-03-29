import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:equations/equations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'dart:async';
import 'package:cosmocannons/overrides.dart';

class GameObject {
  // VARIABLES

  int _team;
  void Function(VoidCallback) updateUI;
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

  List<List<double>> enterPlayerHitboxes(
      Offset actualVelocity, Offset startPos) {
    var playerTimes = List<List<double>>.empty(growable: true);
    List<Complex> times;
    var uX = actualVelocity.dx;
    var uY = actualVelocity.dy * globals.ySF;
    var accelX = globals.Ax;
    var accelY = globals.Ay * globals.ySF;
    var startX = startPos.dx;
    var startY = startPos.dy * globals.ySF;
    var hitboxRadius = 0.02 * 2;

    //every player
    for (var i = 0; i < globals.players.length; i++) {
      var playerX = globals.players[i].aX;
      var playerY = globals.players[i].aY * globals.ySF;

      // get times for x and y
      var quartic = Quartic(
          a: Complex(0.25 * (accelX * accelX + accelY * accelY), 0),
          b: Complex(accelX * uX + accelY * uY, 0),
          c: Complex(
              accelX * (startX - playerX) +
                  uX * uX +
                  accelY * (startY - playerY) +
                  uY * uY,
              0),
          d: Complex(
              2 * uX * (startX - playerX) + 2 * uY * (startY - playerY), 0),
          e: Complex(
              startX * startX +
                  playerX * playerX -
                  2 * startX * playerX +
                  startY * startY +
                  playerY * playerY -
                  2 * startY * playerY -
                  hitboxRadius * hitboxRadius,
              0));
      print('$i = ${quartic.toString()}');
      times = quartic.solutions();
      print('player $i solutions:');
      playerTimes.add(List<double>.empty(growable: true));
      for (var t in times) {
        print('    r=${t.real}');
        print('    i=${t.imaginary}');
        print('');
        if (t.real > 0 && double.parse(t.imaginary.toStringAsFixed(3)) == 0) {
          playerTimes[i].add(t.real * 10);
        }
      }
    }
    print('returns: $playerTimes');
    return playerTimes;
  }

  void draw(Canvas canvas) {
    //define vars
    final paint = Paint()..color = teamColour;

    //draw projectile
    canvas.drawCircle(rPos, 3, paint);
  }

  @override
  String toString() {
    return 'GameObject(aPos:$aPos,rPos:$rPos,team:$team)';
  }
}

class Player extends GameObject {
  // attributes
  bool drawHitbox = true;
  double health = globals.defaultPlayerHealth;
  BuildContext _context;
  bool _isAI = false;
  int playerID;

  //getters
  bool get isAI => _isAI;

  //setters

  // constructors
  /*Player(Offset pos, int team, void Function(VoidCallback) updater,
      BuildContext context) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = globals.defaultPlayerHealth;
    _context = context;
  }*/
  Player.fromListCreated(int p, int n, int team, List<double> terrainHeights,
      void Function(VoidCallback) updater, BuildContext context,
      {bool isAI = false}) {
    updateUI = updater;
    aX = (p + 1) / (n + 1);
    aY = GamePainter().calcNearestHeight(terrainHeights, aX) +
        globals.playerRadiusY;
    _team = team;
    health = globals.defaultPlayerHealth;
    _context = context;
    _isAI = isAI;
    playerID = p;
  }
  Player.withHealth(Offset pos, int team, double h,
      void Function(VoidCallback) updater, BuildContext context, int playerNo,
      {bool isAI = false}) {
    updateUI = updater;
    aPos = pos;
    _team = team;
    health = h;
    _context = context;
    _isAI = isAI;
    playerID = playerNo;
  }

  //methods
  void moveRight() => move(globals.movementAmount);

  void moveLeft() => move(-globals.movementAmount);

  /// Positive is right
  void move(double actualAmount, [bool fromPacket = false]) {
    // LAN
    if (globals.type == globals.GameType.multiHost) {
      //server send to everyone
      globals.server.sendToEveryone(globals.packetPlayerMove,
          actualAmount.toString(), globals.players.length);
    }
    if (globals.type == globals.GameType.multiClient && !fromPacket) {
      //client tell server if the event is not from packet (prevents feedback)
      globals.client
          .sendData(actualAmount.toString(), globals.packetPlayerMove);
    }
    updateUI(() {
      aX = aX + actualAmount;

      //players loop if they move out of zone
      while (aX > 1) {
        aX -= 1;
      }
      while (aX < 0) {
        aX += 1;
      }

      //set y
      aY = GlobalPainter().calcNearestHeight(globals.currentMap, aX) +
          globals.playerRadiusY;

      updated = true;
    });
  }

  /// Randomly picks a player not on it's team unless given specific team.
  /// Accuracy is given between 0 (very innacurate) and 1 (very accurate)
  void playAI(void Function(VoidCallback) updater, int thisPlayer,
      {int teamToTarget, double accuracy}) async {
    //local vars
    var timeSec = 2.0;
    const a = Offset(globals.Ax, globals.Ay);
    var angleVariance = 0.0;
    var uX = 0.0;
    var uY = 0.0;
    var selectedPlayer =
        _selectPlayer(teamToTarget, globals.players[thisPlayer].team);
    Offset u;
    Offset s;
    var rand = Random();

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
    var radiusX = globals.playerRadiusX.toRelativeX();
    var radiusY = (1 - globals.playerRadiusY).toRelativeY();
    var windowWidth = radiusX / 4;
    var topOval = Rect.fromPoints(rPos.translate(-radiusX, -radiusY),
        rPos.translate(radiusX, radiusY * 0.5));
    var midArc = Rect.fromPoints(rPos.translate(-radiusX, radiusY * 2.5),
        rPos.translate(radiusX, -radiusY * 0.5));
    var bottomArc = Rect.fromPoints(
        rPos.translate(-radiusX * 0.7, radiusY * 0.4),
        rPos.translate(radiusX * 0.7, radiusY * 1.6));

    //define paints
    final playerHealthText = globals.defaultTextPaint
      ..text = TextSpan(
          text: (health <= 0 ? 0 : health).toString(), style: UI.defaultText())
      ..layout();
    var playerFill = Paint()
      ..color = teamColour
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    var whiteFill = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    var whiteEmpty = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    var blackFill = Paint()
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
    if (drawHitbox) {
      canvas.drawCircle(rPos, 0.02.toRelativeX(), whiteEmpty);
      //canvas.drawCircle(rPos, 0.05.toRelativeY() / 10, whiteEmpty);
    }
    //draw text
    playerHealthText.paint(
        canvas,
        rPos.translate(
            -playerHealthText.width / 2, -radiusY - playerHealthText.height));
  }

  @override
  String toString() {
    return 'Player(health:$health, team:$team, pos:$aPos)';
  }

  int _selectPlayer(int teamToTarget, int playerTeam) {
    //locals
    var playersToChoose = List<int>.empty(growable: true);
    var rand = Random();

    // add players to target list
    if (teamToTarget != null &&
        teamToTarget != playerTeam &&
        globals.players.any((element) => element.team == teamToTarget)) {
      //teamToTarget exists in array
      for (var i = 0; i < globals.players.length; i++) {
        if (globals.players[i].team == teamToTarget) playersToChoose.add(i);
      }
    } else {
      //select random player not on team
      for (var i = 0; i < globals.players.length; i++) {
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
  Offset get aS => aPos;
  double get time => _timeSec;
  Offset get aStart => _startPos;
  int get playerInt => _player;
  Player get playerObj => globals.players[playerInt];

  Projectile.velocity(
      Offset velocity, int player, void Function(VoidCallback) updater) {
    _projectileRunner(velocity, player, updater);
  }
  Projectile.radians(double intensity, double angleRadians, int player,
      void Function(VoidCallback) updater) {
    _projectileRunner(angleToOffset(intensity, angleRadians), player, updater);
  }
  Projectile.degrees(double intensity, double angleDegrees, int player,
      void Function(VoidCallback) updater) {
    _projectileRunner(
        angleToOffset(intensity, angleDegrees * globals.degreesToRadians),
        player,
        updater);
  }

  Offset angleToOffset(double intensity, double angleRadians) {
    return Offset(
        intensity * -cos(angleRadians), intensity * sin(angleRadians));
  }

  void _projectileRunner(
      Offset velocity, int player, void Function(VoidCallback) updater,
      {firstShot = false}) async {
    //set stuff up
    updateUI = updater;
    _player = player;
    _team = playerObj.team;

    //set set u,a,s
    _u = velocity;
    _a = Offset(globals.Ax, globals.Ay);
    aPos = playerObj.aPos;

    var playerHit = await _animateProjectile();

    if (globals.useExplosions) {
      _createExplosion(rPos);
    } else {
      _giveDamage(playerHit, firstShot, playerObj._context);
    }
    _nextPlayer();
    _checkWinner(playerObj._context);

    //destroy now
    updateUI(() {
      globals.projectiles.remove(this);
      if (globals.projectiles.isEmpty) {
        globals.firing = false;
        globals.popup = false;
      }
    });

    //singleplayer run AI
    if (globals.players[globals.currentPlayer].isAI &&
        globals.type == globals.GameType.singlePlayer) {
      globals.players[globals.currentPlayer]
          .playAI(updater, globals.currentPlayer);
    }
  }

  void _createExplosion(Offset impactPos) {
    //update UI periodically
    void Function(Timer time) callback = (Timer time) {
      _explosionCallback(time, impactPos);
    };
    Timer.periodic(Duration(milliseconds: globals.frameLengthMs), callback);
  }

  void _explosionCallback(Timer timer, Offset impactPos) {
    //locals
    var max = 10;
    var min = 2;
    var rand = Random();
    var angle = 1.0;

    //set position

    if (timer.tick > 20) {
      updateUI(() {});
      if (globals.particles.isEmpty) {
        timer.cancel();
      }
    } else {
      //add particles
      updateUI(() {
        for (var i = 0; i < rand.nextInt(max - min) + max - min; i++) {
          angle = rand.nextDouble() * pi * 2;
          globals.particles.add(
              ExplosionParticle(Offset.fromDirection(angle), impactPos, team));
        }
      });
    }
  }

  Future<int> _animateProjectile() async {
    globals.firing = true;
    const length = Duration(milliseconds: globals.frameLengthMs);
    const check = Duration(milliseconds: globals.frameLengthMs);
    Timer timer;

    //set projectile
    _timeSec = 0;
    aPos = playerObj.aPos;

    //calculate hitbox entires
    var hitboxTimes = enterPlayerHitboxes(_u, aPos);
    var smallestTime = double.infinity;
    var playerHit = -1;
    //player hitting
    print(hitboxTimes);
    for (var i = 0; i < hitboxTimes.length; i++) {
      if (hitboxTimes[i].isNotEmpty && globals.players[i].team != team) {
        print('player $i team=${globals.players[i].team} projectile=$team');
        print('${hitboxTimes[i][0]}');
        if (hitboxTimes[i][0] < smallestTime) {
          smallestTime = hitboxTimes[i][0];
          playerHit = i;
        }
        ;
      }
    }

    //fire projectile
    timer = Timer.periodic(length, (timer) {
      _renderCallback(timer, smallestTime);
    });

    // wait until flight over or long flight
    while (timer.isActive) {
      await Future.delayed(check);
    }

    //cancel ticker and remove from UI
    timer.cancel();
    return playerHit;
  }

  void _renderCallback(Timer timer, double smallestTime) {
    //set time
    var hitPlayer = false;
    var terrainHeight = 0.0;
    var tick = timer.tick;
    _timeSec = (globals.frameLengthMs * tick) / 1000;

    updateUI(() {
      //set new locations
      updated = true;

      // s = ut + 0.5att
      aX = playerObj.aX +
          (_u.dx * _timeSec + 0.5 * _a.dx * _timeSec * _timeSec) * globals.xSF;
      aY = playerObj.aY +
          (_u.dy * _timeSec + 0.5 * _a.dy * _timeSec * _timeSec) * globals.ySF;
    });

    // hit terrain?
    terrainHeight = GlobalPainter().calcNearestHeight(globals.currentMap, aX);

    //hit player?
    hitPlayer = smallestTime <= _timeSec;

    //stop when done
    if (terrainHeight >= aY ||
        hitPlayer ||
        _timeSec > globals.maxFlightLength) {
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
    if (globals.currentPlayer >= globals.players.length) {
      globals.currentPlayer = 0;
    }
    if (globals.type.showPlayerUI(globals.currentPlayer)) {
      globals.thisPlayer = globals.currentPlayer;
    }
    //server get's final choice over who is playing
    if (globals.type == globals.GameType.multiHost) {
      globals.server.sendToEveryone(globals.packetPlayersTurn,
          globals.currentPlayer.toString(), globals.players.length);
    }
  }

  void _giveDamage(int hitPlayer, bool firstShot, BuildContext context) async {
    //locals

    if (hitPlayer != -1) {
      if (globals.players[hitPlayer].team != playerInt) {
        //player in blast radius administer damage
        updateUI(() {
          globals.players[hitPlayer].health -= globals.blastDamage;
          globals.players[hitPlayer].updated = true;
        });

        if (firstShot) await UI.addAchievement(0, context);

        //remove dead players
        updateUI(() {
          if (globals.players[hitPlayer].health <= 0) {
            globals.players.removeAt(hitPlayer);
            //if player killed is below the current player then the current player needs updating
            if (hitPlayer < globals.currentPlayer) {
              globals.currentPlayer--;
              _player--;
            }
          }
        });
      }
    }
  }

  void _checkWinner(BuildContext context) async {
    if (globals.players.isEmpty) {
      //Players wiped each other out
      await UI.dataStore(globals.keySavedGame, false);
      await UI.dataInputPopup(context, [null],
          notInput: true,
          data: ['You wiped each other out!'], onFinish: (bool b) {
        UI.startNewPage(context, [], newPage: LauncherPage());
      });
      updateUI(() {});
    } else {
      //check amount of teams in play
      var teamsLeft = List<int>.empty(growable: true);
      int playersTeam;

      for (var p = 0; p < globals.players.length; p++) {
        playersTeam = globals.players[p].team;
        //team not in list
        if (teamsLeft.lastIndexOf(playersTeam) == -1) {
          teamsLeft.add(playersTeam);
        }
      }

      if (teamsLeft.length == 1) {
        // last team wins
        // achievement: Champion
        if (teamsLeft[0] == 0 &&
            globals.type == globals.GameType.singlePlayer) {
          await UI.addAchievement(1, context);
        }
        // achievement: Maximum Health
        if (globals.players[0].health == globals.defaultPlayerHealth &&
            globals.type == globals.GameType.singlePlayer) {
          await UI.addAchievement(2, context);
        }

        //unsave last game
        await UI.dataStore(globals.keySavedGame, false);
        await UI.dataInputPopup(context, [null],
            notInput: true,
            data: ['Team ${globals.defaultTeamNames[teamsLeft[0]]} has won!'],
            onFinish: (bool b) {
          UI.startNewPage(context, [], newPage: LauncherPage());
        });
        updateUI(() {});
      }
    }
  }
}

class ExplosionParticle extends GameObject {
  /// The normalised vector of the player direction
  Offset direction;

  /// The time the explosion was created
  DateTime time;

  ExplosionParticle(Offset _direction, Offset locationRelative, int team) {
    //update properties
    rPos = locationRelative;
    direction = _direction / _direction.distance;
    time = DateTime.now();
    _team = team;

    //calculate potential collision
    //enterPlayerHitboxes(direction, aPos); // TODO finish this
  }
}
