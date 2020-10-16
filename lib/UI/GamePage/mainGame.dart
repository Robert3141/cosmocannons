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
  MainGamePage({Key key, this.title, this.type}) : super(key: key);

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
  int playerNumber;
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
      //based on paused or unpaused
      if (paused) {
        //paused
      } else {
        //unpaused
      }
    });
  }

  void playerMove(bool right) {
    double playerX = globals.playerPos[playerNumber][0];
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
    playerY = 1 - GamePainter().calcNearestHeight(gameMap, playerX);
    setState(() {
      globals.playerPos[playerNumber] = [playerX, playerY];
    });
  }

  void doubleTap() {
    //get positions
    double tapX = tapDetails.localPosition.dx;
    double tapY = tapDetails.localPosition.dy;
    double playerX;
    double playerY;
    double intensity = double.parse(globals.defaultFireSetup[0]);
    double angle = double.parse(globals.defaultFireSetup[1]);
    int player = playerNumber;

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
      //show popup
      setState(() {
        UI.dataInputPopup(
            context,
            [
              (String text) => intensity = double.parse(text),
              (String text) => angle = double.parse(text)
            ],
            dataTitle: globals.shootOptions,
            title: globals.shootSetup,
            data: globals.defaultFireSetup,
            numericData: [true, true],
            barrierDismissable: false, onFinish: () {
          //code after player finished
          playerShoot(intensity, angle);
        });
      });
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

  void playerShoot(double intensity, double angleDegrees) async {
    //simulate particle
    double angleRadians = angleDegrees * globals.degreesToRadians;
    double uX = intensity * -cos(angleRadians);
    double aX = globals.Ax;
    double sX;
    double uY = intensity * sin(angleRadians);
    double aY = globals.Ay;
    double sY = 0;
    double t;
    List<double> tempT;

    //calulate time taken for level firing
    tempT = solveQuadratic(0.5 * aY, uY, -sY) ?? [0, 0];
    t = tempT[0] <= 0
        ? tempT[1] <= 0
            ? 0
            : tempT[1]
        : tempT[0];

    //render correct amount of times
    for (int i = 0; i < t * (1 / (globals.frameLengthMs / 1000)); i++) {
      setState(() {
        // s = ut + 0.5att
        sX = uX * t + 0.5 * aX * i * i;
        sY = uY * t + 0.5 * aY * i * i;

        globals.projectilePos = [sX, sY];
      });
      await Future.delayed(Duration(milliseconds: globals.frameLengthMs));
    }
  }

  void gameStart() {}

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
          //moveScroller(-globals.scrollAmount);
        }
        if (keyPress == LogicalKeyboardKey.arrowRight && playersTurn) {
          //move right
          playerMove(true);
          //moveScroller(globals.scrollAmount);
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
    pageContext = context;
    playersTurn = widget.type.startingPlayer ?? true;
    playerNumber = widget.type.playerNumber ?? 0;
    Color playerButtonColour =
        globals.teamColors[globals.playerTeams[playerNumber]] ??
            globals.textColor;
    Scaffold page = UI.scaffoldWithBackground(children: [
      Stack(
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
                child: CustomPaint(
                  size: Size(
                      UI.screenWidth(context) * zoom, UI.screenHeight(context)),
                  painter: GamePainter(),
                ),
              ),
            ),
          ),
          //pause menu
          paused
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
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
                icon: Icon(paused ? Icons.play_arrow : Icons.pause,
                    color: globals.textColor),
                iconSize: globals.iconSize,
                onPressed: () {
                  pausePress();
                }),
          ),
          //player arrow buttons
          playersTurn
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
          playersTurn
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
