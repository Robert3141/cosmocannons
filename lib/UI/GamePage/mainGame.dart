import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
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
    playerY = GamePainter().calcNearestHeight(gameMap, playerX);
    setState(() {
      globals.playerPos[playerNumber] = [playerX, playerY];
      print("POS" + globals.playerPos.toString());
    });
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
              child: CustomPaint(
                size: Size(
                    UI.screenWidth(context) * zoom, UI.screenHeight(context)),
                painter: GamePainter(),
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

class GamePainter extends CustomPainter {
  //locals
  Size canvasSize;
  List<List<double>> currentPlayerPos;

  Offset relativePos(double x, double y) {
    //takes x & y between 0 and 100
    //returns size based on screen
    double newX = x * canvasSize.width;
    double newY = y * canvasSize.height;
    return Offset(newX, newY);
  }

  Offset relPos(Offset pos) {
    // takes x and y between 0 and 1
    // return size based on screen
    return Offset(pos.dx * canvasSize.width, pos.dy * canvasSize.height);
  }

  void drawPlayer(int colour, List<double> pos, Canvas canvas) {
    Offset position = Offset(pos[0], pos[1]);
    final paint = Paint()
      ..color = globals.teamColors[colour]
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    canvas.drawCircle(relPos(position), 10, paint);
  }

  void spawnInPlayers(
      List<int> playerColours, List<double> terrainHeights, Canvas canvas) {
    int amountOfPlayers = playerColours.length;
    double playerY = 0.0;
    double playerX = 0.0;
    //empty only on first render
    if (globals.firstRender) {
      globals.playerPos = new List.filled(amountOfPlayers, [0, 0]);
    }

    for (int players = 0; players < amountOfPlayers; players++) {
      //place in player on firstRender calculate pos
      if (globals.firstRender) {
        playerX = (players + 1) / (amountOfPlayers + 1);
        playerY = calcNearestHeight(terrainHeights, playerX);
        globals.playerPos[players] = [playerX, 1 - playerY];
        print("first render");
      }
      currentPlayerPos = globals.playerPos;
      print(currentPlayerPos);
      drawPlayer(playerColours[players], globals.playerPos[players], canvas);
    }
  }

  double calcNearestHeight(List<double> terrainHeights, double relPos) {
    //return nearest index int
    int nearestIndex = (relPos * terrainHeights.length).floor();
    nearestIndex = nearestIndex >= terrainHeights.length
        ? terrainHeights.length - 1
        : nearestIndex;
    return terrainHeights[nearestIndex];
  }

  void generateTerrain(List<double> terrainHeights, Canvas canvas) {
    int xAmount = globals.terrainRowsToRender;
    int yAmount = globals.terrainColumnsToRender;
    int red;
    int blue;
    int green;
    int minFractionFloor;
    List<Color> colors = globals.terrainColors;
    Color blockColor;
    Color colorAbove;
    Color colorBelow;
    double heightPos;
    double fractionThere;
    double smoothedHeight;
    double relativeX1;
    double relativeX;
    Offset posBL;
    Offset posTR;

    //loop through columns
    for (int x = 1; x <= xAmount; x++) {
      //loop through rows
      for (int y = 1; y <= yAmount; y++) {
        //calculate the nearest mapping value to estimate height at
        relativeX = x / xAmount;
        smoothedHeight = calcNearestHeight(terrainHeights, relativeX);
        heightPos = y / yAmount;
        if (smoothedHeight > heightPos) {
          //square vertex positions
          relativeX = x / xAmount;
          relativeX1 = (x - 1) / xAmount;
          posBL = Offset(relativeX1, 1 - ((y - 1) / yAmount));
          posTR = Offset(relativeX, 1 - (y / yAmount));

          //choose colour
          fractionThere = (heightPos / smoothedHeight) * (colors.length - 1);
          minFractionFloor = fractionThere.floor() == colors.length - 1
              ? colors.length - 2
              : fractionThere.floor();
          colorBelow = colors[minFractionFloor];
          colorAbove = colors[minFractionFloor + 1];
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
          final paint = Paint()
            ..color = blockColor
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.square;
          canvas.drawRect(Rect.fromPoints(relPos(posBL), relPos(posTR)), paint);
        }
      }
    }
    canvas.save();
    globals.terrainCanvas = canvas;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvasSize = size;
    List<double> gameMap = globals.terrainMaps[0];

    //render terrain
    if (globals.firstRender) {
      generateTerrain(gameMap, canvas);
    } else {
      //use dirty canvas:
      canvas = globals.terrainCanvas;
      canvas.restore();
    }

    //place in characters
    spawnInPlayers(globals.playerTeams, gameMap, canvas);
    globals.firstRender = false;
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    if (currentPlayerPos == globals.playerPos) {
      return false;
    } else {
      return true;
    }
  }
}
