import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
    print(pos);
    double offsetX = globals.gameScroller.position.maxScrollExtent * pos[0];
    setState(() {
      print(globals.gameScroller.offset);
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
    if (tapX > playerX - globals.tapNearPlayer &&
        tapX < playerX + globals.tapNearPlayer &&
        tapY > playerY - globals.tapNearPlayer &&
        tapY < playerY + globals.tapNearPlayer) {
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

  Future<bool> animateProjectile(double intensity, double angleDegrees) async {
    //simulate particle
    double angleRadians = angleDegrees * globals.degreesToRadians;
    double uX = intensity * -cos(angleRadians);
    double aX = globals.Ax;
    double sX = 0;
    double uY = intensity * sin(angleRadians);
    double aY = globals.Ay;
    double sY = 0;
    double terrainHeight = 0;
    double playerX = globals.playerPos[globals.currentPlayer][0];
    double playerY = globals.playerPos[globals.currentPlayer][1] + 0.01;
    double timeSec = 0;
    //List<double> tempT;
    Timer animationTimer;
    bool tickerActive;

    //calulate time taken for level firing
    /*tempT = solveQuadratic(0.5 * aY, uY, -sY) ?? [0, 0];
    t = tempT[0] <= 0
        ? tempT[1] <= 0
            ? 0
            : tempT[1]
        : tempT[0];*/

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
    });

    //return false if too long
    while (animationTimer.isActive && timeSec <= globals.maxFlightLength) {
      await Future.delayed(Duration(milliseconds: globals.checkDoneMs));
    }

    //cancel ticker and remove projectile from UI
    tickerActive = animationTimer.isActive;
    animationTimer.cancel();
    globals.projectilePos = globals.locationInvisible;
    return !tickerActive;
  }

  void nextPlayer() {
    int playerInt = globals.currentPlayer;
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
    bool firingLanded;

    setState(() {
      //disable shoot UI
      globals.thisPlayer = -1;
    });

    //shoot projectile
    firingLanded = await animateProjectile(intensity, angleDegrees);

    setState(() {
      //set next player
      nextPlayer();
    });
  }

  void gameStart() {
    // depends on game mode
    globals.currentPlayer = widget.type.playerNumber;

    //not start anymore
    startOfGame = false;
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
