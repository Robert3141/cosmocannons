import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:flutter/services.dart';

class MainGamePage extends StatefulWidget {
  //constructor of class
  MainGamePage(
      {Key key, this.title = "", this.type = globals.GameType.multiLocal})
      : super(key: key);

  final String title;
  final globals.GameType type;

  @override
  _MainGamePageState createState() {
    globals.firstRender = true;
    return _MainGamePageState();
  }
}

class _MainGamePageState extends State<MainGamePage> {
  //locals
  double zoom = globals.defaultZoom;
  int amountOfPlayers;
  bool startOfGame = true;
  bool paused = false;
  bool playersTurn = true;
  BuildContext pageContext;
  List<double> gameMap = globals.terrainMaps[0];
  TapDownDetails tapDetails;

  //functions
  void pausePress() {
    setState(() {
      paused = !paused;
      globals.popup = paused;
      //based on paused or unpaused
      if (paused) {
        //paused
      } else {
        //unpaused
      }
    });
  }

  void moveScrollerToRelativePosition(List<double> pos) {
    double offsetX = globals.gameScroller.position.maxScrollExtent * pos[0];
    setState(() {
      globals.gameScroller.animateTo(offsetX,
          curve: Curves.bounceIn,
          duration: Duration(milliseconds: globals.animationSpeed.round()));
    });
  }

  void playerMove(bool right) {
    double playerX = globals.playerPos[globals.currentPlayer][0];
    double playerY;
    playerX = right
        ? playerX + globals.movementAmount
        : playerX - globals.movementAmount;
    //make sure playerX is always between 0 and 1
    playerX = playerX > 1
        ? 1
        : playerX < 0
            ? 0
            : playerX;
    playerY = GamePainter().calcNearestHeight(gameMap, playerX) +
        globals.playerPadding;
    setState(() {
      globals.playerPos[globals.currentPlayer] = [playerX, playerY];
    });
  }

  void doubleTap() {
    //get positions
    double tapX = tapDetails.localPosition.dx;
    double tapY = UI.screenHeight(context) - tapDetails.localPosition.dy;
    double playerX;
    double playerY;
    int player = globals.currentPlayer;

    //set player locations
    playerX = globals.playerPos[player][0] *
        UI.screenWidth(context) *
        globals.defaultZoom;
    playerY = globals.playerPos[player][1] * UI.screenHeight(context);

    //check near player
    if (checkInRadius(
            [tapX, tapY], [playerX, playerY], globals.tapNearPlayer) &&
        playersTurn &&
        !globals.popup) {
      playerShootTap();
    }
  }

  List<double> solveQuadratic(double a, double b, double c) {
    double discriminant = b * b - (4 * a * c);
    if (discriminant >= 0) {
      double x1 = (-b + sqrt(discriminant)) / (2 * a);
      double x2 = (-b - sqrt(discriminant)) / (2 * a);
      return [x1, x2];
    } else {
      return null;
    }
  }

  void playerShootTap() {
    //local variables
    double intensity = double.parse(globals.defaultFireSetup[0]);
    double angle = double.parse(globals.defaultFireSetup[1]);

    //show popup
    setState(() {
      UI.dataInputPopup(
          context,
          [
            (String text) => intensity = double.tryParse(text) ?? 0,
            (String text) => angle = double.tryParse(text) ?? 0,
          ],
          dataTitle: globals.shootOptions,
          title: globals.shootSetup,
          data: globals.defaultFireSetup,
          numericData: [true, true],
          barrierDismissable: true, onFinish: (bool confirm) {
        //code after player finished
        setState(() {
          globals.popup = false;
        });
        if (confirm) playerShoot(intensity, angle);
      });

      //move terrain to player
      moveScrollerToRelativePosition(globals.playerPos[globals.currentPlayer]);
    });
  }

  Future<List<double>> animateProjectile(
      double intensity, double angleDegrees, int playerInt) async {
    //simulate particle
    double angleRadians = angleDegrees * globals.degreesToRadians;
    double uX = intensity * -cos(angleRadians);
    double aX = globals.Ax;
    double sX = 0;
    double uY = intensity * sin(angleRadians);
    double aY = globals.Ay;
    double sY = 0;
    double terrainHeight = 0;
    double playerX = globals.playerPos[playerInt][0];
    double playerY = globals.playerPos[playerInt][1] + 0.01;
    double timeSec = 0;
    /*double t;
    List<double> levelTime;*/
    Timer animationTimer;
    List<double> impactPos = globals.locationInvisible;

    //calulate time taken for level firing
    /*levelTime = solveQuadratic(0.5 * aY, uY, -sY) ?? [0, 0];
    t = levelTime[0] <= 0
        ? levelTime[1] <= 0
            ? 0
            : levelTime[1]
        : levelTime[0];*/

    //render correct amount of time
    animationTimer =
        Timer.periodic(Duration(milliseconds: globals.frameLengthMs), (timer) {
      //amount of times called
      int tick = timer.tick;
      timeSec = (globals.frameLengthMs * tick * globals.animationSpeed) / 1000;

      //rebuild with new location
      setState(() {
        // s = ut + 0.5att
        sX = (uX * timeSec + 0.5 * aX * timeSec * timeSec) * globals.xSF +
            playerX;
        sY = (uY * timeSec + 0.5 * aY * timeSec * timeSec) * globals.ySF +
            playerY;

        globals.projectilePos = [sX, sY];
      });

      //stop when done
      terrainHeight = GamePainter().calcNearestHeight(gameMap, sX);
      if (terrainHeight >= sY) {
        timer.cancel();
      }
      // stop if going to take too long!
      /*if (t > globals.maxFlightLength) {
        globals.projectilePos = globals.locationInvisible;
        timer.cancel();
      }*/
    });

    //wait until flight over or long flight
    while (animationTimer.isActive && timeSec <= globals.maxFlightLength) {
      await Future.delayed(Duration(milliseconds: globals.checkDoneMs));
    }

    //cancel ticker and remove projectile from UI
    animationTimer.cancel();
    impactPos = globals.projectilePos ?? globals.locationInvisible;
    globals.projectilePos = globals.locationInvisible;
    return impactPos;
  }

  bool takeDamage(List<double> impactPos, int playerInt) {
    //local vars
    int currentPlayerTeam = globals.playerTeams[playerInt];
    int amountRemaining = 0;

    //check for all players
    for (int i = 0; i < amountOfPlayers; i++) {
      //only check for players not in team
      if (globals.playerTeams[i] != currentPlayerTeam) {
        if (checkInRadius(
            impactPos, globals.playerPos[i], globals.blastRadius)) {
          //reduce player health
          globals.playerHealth[i] += globals.blastDamage;
        }
      }

      //check amount of players remaining
      if (globals.playerHealth[i] > 0) amountRemaining++;
    }

    return amountRemaining <= 1;
  }

  void nextPlayer(int playerInt) {
    //next player
    playerInt++;

    //check for overflow
    if (playerInt == globals.playerTeams.length) {
      playerInt = 0;
    }

    globals.currentPlayer = playerInt;
    globals.thisPlayer =
        widget.type.showPlayerUI(playerInt) ? playerInt : globals.thisPlayer;
  }

  Future<void> playerShoot(double intensity, double angleDegrees) async {
    //set locals
    List<double> impactPos;
    int playerInt = globals.currentPlayer;
    bool oneOrLessPlayers;
    int winningPlayer;

    setState(() {
      //disable shoot UI
      globals.thisPlayer = -1;
    });

    //shoot projectile
    impactPos = await animateProjectile(intensity, angleDegrees, playerInt);
    print(impactPos);

    //take damage
    oneOrLessPlayers = takeDamage(impactPos, playerInt);
    print(oneOrLessPlayers);

    //game dictates on player health
    if (oneOrLessPlayers) {
      //find winning player
      winningPlayer = -2; //signifies draw

      for (int i = 0; i < amountOfPlayers; i++) {
        if (globals.playerHealth[i] > 0) winningPlayer = i;
      }

      //exit to main menu with popup
      UI.startNewPage(context,
          newPage: LauncherPage(
            winner: winningPlayer,
          ));
    } else {
      //set next player
      setState(() {
        nextPlayer(playerInt);
      });
    }
  }

  bool checkInRadius(
      List<double> item, List<double> hitbox, double hitboxRadius) {
    return item[0] > hitbox[0] - hitboxRadius &&
        item[0] < hitbox[0] + hitboxRadius &&
        item[1] > hitbox[1] - hitboxRadius &&
        item[1] < hitbox[1] + hitboxRadius;
  }

  void gameStart() {
    // depends on game mode
    globals.currentPlayer = widget.type.playerNumber;
    globals.thisPlayer = globals.currentPlayer;

    //not start anymore
    startOfGame = false;

    //set amount of players
    amountOfPlayers = globals.playerTeams.length;

    //reset health
    globals.playerHealth = List.empty(growable: true);
    for (int i = 0; i < amountOfPlayers; i++) {
      globals.playerHealth.add(globals.defaultPlayerHealth);
    }
  }

  void moveScroller(double increase) {
    double currentPos = globals.gameScroller.offset;
    double newPos = currentPos + increase;
    double maxPos = UI.screenWidth(context) * zoom * 0.5;
    newPos = newPos >= 0
        ? newPos < maxPos
            ? newPos
            : maxPos
        : 0;
    globals.gameScroller.jumpTo(newPos);
  }

  void keyPresses(RawKeyEvent key) {
    //only take key down events not key up as well
    if (key.runtimeType == RawKeyDownEvent) {
      //only take most inputs when not paused
      if (!paused) {
        String keyChar = key.data.keyLabel ?? "";
        KeyboardKey keyPress = key.logicalKey;
        switch (keyChar) {
          case "a":
            //move left
            moveScroller(-globals.scrollAmount);
            break;
          case "d":
            //move right
            moveScroller(globals.scrollAmount);
            break;
        }
        if (keyPress == LogicalKeyboardKey.arrowLeft && playersTurn) {
          //move left
          playerMove(false);
        }
        if (keyPress == LogicalKeyboardKey.arrowRight && playersTurn) {
          //move right
          playerMove(true);
        }
        if (keyPress == LogicalKeyboardKey.enter) {
          //fire!!
          playerShootTap();
        }
      }
      //always on keyboard controls
      if (key.logicalKey == LogicalKeyboardKey.escape) {
        pausePress();
      }
    }
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    if (startOfGame) gameStart();
    pageContext = context;
    playersTurn = globals.thisPlayer == globals.currentPlayer;
    Color playerButtonColour =
        globals.teamColors[globals.playerTeams[globals.currentPlayer]] ??
            globals.textColor;
    Scaffold page = UI.scaffoldWithBackground(children: [
      Stack(
        alignment: Alignment.center,
        children: [
          //main terrain
          SingleChildScrollView(
            controller: globals.gameScroller,
            scrollDirection: Axis.horizontal,
            //scrollable based on pause
            physics: paused
                ? NeverScrollableScrollPhysics()
                : AlwaysScrollableScrollPhysics(),
            child: RawKeyboardListener(
              autofocus: true,
              onKey: keyPresses,
              focusNode: globals.gameInputs,
              child: GestureDetector(
                onDoubleTap: () => tapDetails == null ? () {} : doubleTap(),
                onTapDown: (details) {
                  tapDetails = details;
                },
                onDoubleTapDown: (details) {
                  tapDetails = details;
                },
                child: CustomPaint(
                  size: Size(
                      UI.screenWidth(context) * zoom, UI.screenHeight(context)),
                  painter: GamePainter(),
                ),
              ),
            ),
          ),
          //pause menu
          (paused && globals.popup)
              ? Container(
                  //give a disabled effect
                  color: globals.disabledBorder,
                  width: UI.screenWidth(context),
                  height: UI.screenHeight(context),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      //columnof actual data
                      children: [
                        UI.topTitle(
                            titleText: globals.paused,
                            context: context,
                            root: true),
                      ],
                    ),
                  ),
                )
              : Container(),
          //pause button
          (globals.popup && paused) || (!globals.popup)
              ? Positioned(
                  right: 0.0,
                  top: 0.0,
                  child: IconButton(
                      icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                          color: globals.textColor),
                      iconSize: globals.iconSize,
                      onPressed: () {
                        pausePress();
                      }),
                )
              : Container(),
          //player arrow and shoot buttons
          playersTurn && !globals.popup
              ? Positioned(
                  left: 0.0,
                  bottom: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded,
                        color: playerButtonColour),
                    iconSize: globals.iconSize,
                    onPressed: () => playerMove(false),
                  ),
                )
              : Container(),
          playersTurn && !globals.popup
              ? Positioned(
                  //left: 0.0,
                  //right: 0.0,
                  bottom: 0.0,
                  child: IconButton(
                    icon: Icon(
                      Icons.bubble_chart,
                      color: playerButtonColour,
                    ),
                    iconSize: globals.iconSize,
                    onPressed: () => playerShootTap(),
                  ),
                )
              : Container(),
          playersTurn && !globals.popup
              ? Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios_rounded,
                        color: playerButtonColour),
                    iconSize: globals.iconSize,
                    onPressed: () => playerMove(true),
                  ),
                )
              : Container(),
        ],
      ),
    ], context: context, padding: false);
    return page;
  }
}
