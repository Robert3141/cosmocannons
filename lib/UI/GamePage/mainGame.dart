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
      {@required this.playerTeams,
      Key key,
      this.title = "",
      this.type = globals.GameType.multiLocal,
      this.resumed = false,
      this.mapNo = globals.defaultMap})
      : super(key: key);

  final String title;
  final globals.GameType type;
  final List<int> playerTeams;
  final bool resumed;
  final int mapNo;

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
  int currentPlayer;
  int thisPlayer;
  bool startOfGame = true;
  bool paused = false;
  bool playersTurn = true;
  bool loaded = true;
  bool movedPlayer = false;
  BuildContext pageContext;
  List<int> playerTeams;
  List<List<double>> lastFireSetup;
  TapDownDetails tapDetails;

  ///
  /// FUNCTIONS
  ///

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
    double startX = globals.turretPos[playerInt][0];
    double startY = globals.turretPos[playerInt][1];
    double timeSec = 0;
    double distanceToPlayer = 1;
    double distanceToPlayerX;
    double distanceToPlayerY;
    bool hitPlayer = false;
    Timer animationTimer;
    List<double> impactPos = globals.locationInvisible;
    List<double> playerCenter;

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
            startX;
        sY = (uY * timeSec + 0.5 * aY * timeSec * timeSec) * globals.ySF +
            startY;

        globals.projectilePos = [sX, sY];
      });

      //hit terrain?
      terrainHeight = GamePainter(currentPlayer, playerTeams, lastFireSetup)
          .calcNearestHeight(globals.currentMap, sX);

      //hit player?
      hitPlayer = false;
      for (int p = 0; p < amountOfPlayers; p++) {
        playerCenter = globals.playerPos[p].toList();
        playerCenter[1] += globals.blastRadius;
        if (checkInRadius([sX, sY], playerCenter, globals.blastRadius)) {
          distanceToPlayerX = playerCenter[0] - sX;
          distanceToPlayerY = playerCenter[1] - sY;
          if (distanceToPlayer >
              sqrt(distanceToPlayerX * distanceToPlayerX +
                  distanceToPlayerY * distanceToPlayerY)) {
            distanceToPlayer = sqrt(distanceToPlayerX * distanceToPlayerX +
                distanceToPlayerY * distanceToPlayerY);
          } else {
            hitPlayer = true;
          }
        }
      }

      //stop when done
      if (terrainHeight >= sY || hitPlayer) {
        timer.cancel();
      }
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
    int currentPlayerTeam = playerTeams[playerInt];
    int amountRemaining = 0;
    double dx;
    double dy;
    double distanceOfRadius;
    List<double> centreOfPlayer;

    //check for all players
    for (int i = 0; i < amountOfPlayers; i++) {
      //only check for players not in team
      if (playerTeams[i] != currentPlayerTeam) {
        //centre of player
        centreOfPlayer = globals.playerPos[i].toList();
        centreOfPlayer[1] += globals.blastRadius;

        if (checkInRadius(impactPos, centreOfPlayer, globals.blastRadius)) {
          //distance from blast radius
          dx = centreOfPlayer[0] - impactPos[0];
          dy = centreOfPlayer[1] - impactPos[1];
          distanceOfRadius =
              1 - (sqrt(dx * dx + dy * dy) / (globals.blastRadius * 2));

          //reduce player health
          globals.playerHealth[i] += globals.blastDamage * distanceOfRadius;
        }
      }

      //check amount of players remaining
      if (globals.playerHealth[i] > 0) amountRemaining++;
    }

    return amountRemaining <= 1;
  }

  bool checkInRadius(
      List<double> item, List<double> hitbox, double hitboxRadius) {
    return item[0] > hitbox[0] - hitboxRadius &&
        item[0] < hitbox[0] + hitboxRadius &&
        item[1] > hitbox[1] - hitboxRadius &&
        item[1] < hitbox[1] + hitboxRadius;
  }

  ///
  /// SUBROUTINES
  ///

  Future<void> playerShoot(double intensity, double angleDegrees) async {
    try {
      //set locals
      List<double> impactPos;
      int playerInt = currentPlayer;
      bool oneOrLessPlayers;
      int winningPlayer;

      setState(() {
        //disable shoot UI
        thisPlayer = -1;
      });

      //shoot projectile
      impactPos = await animateProjectile(intensity, angleDegrees, playerInt);

      //take damage
      oneOrLessPlayers = takeDamage(impactPos, playerInt);

      //game dictates on player health
      if (oneOrLessPlayers) {
        //find winning player
        winningPlayer = -2; //signifies draw

        for (int i = 0; i < amountOfPlayers; i++) {
          if (globals.playerHealth[i] > 0) winningPlayer = i;
        }

        //exit to main menu with popup
        UI.startNewPage(context, [],
            newPage: LauncherPage(
              winner: winningPlayer,
              playerTeams: playerTeams,
            ));
      } else {
        //set next player
        setState(() {
          nextPlayer(playerInt);
        });
      }
    } catch (e) {
      outputError(e);
    }
  }

  void pausePress() {
    try {
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
    } catch (e) {
      outputError(e);
    }
  }

  void moveScrollerToRelativePosition(List<double> pos) {
    try {
      double offsetX = globals.gameScroller.position.maxScrollExtent * pos[0];
      setState(() {
        globals.gameScroller.animateTo(offsetX,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: globals.animationSpeed.round()));
      });
    } catch (e) {
      outputError(e);
    }
  }

  void playerMove(bool right) {
    try {
      double playerX = globals.playerPos[currentPlayer][0];
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
      playerY = GamePainter(currentPlayer, playerTeams, lastFireSetup)
              .calcNearestHeight(globals.currentMap, playerX) +
          globals.playerPadding;
      setState(() {
        movedPlayer = true;
        globals.playerPos[currentPlayer] = [playerX, playerY];
      });
    } catch (e) {
      outputError(e);
    }
  }

  void doubleTap() {
    try {
      //get positions
      double tapX = tapDetails.localPosition.dx;
      double tapY = UI.screenHeight(context) - tapDetails.localPosition.dy;
      double playerX;
      double playerY;
      int player = currentPlayer;

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
    } catch (e) {
      outputError(e);
    }
  }

  void playerShootTap() {
    try {
      //local variables
      double intensity = lastFireSetup[currentPlayer][0];
      double angle = lastFireSetup[currentPlayer][1];
      List<String> fireSetupString = [
        intensity.round().toString(),
        angle.round().toString()
      ];

      //show popup
      setState(() {
        UI.dataInputPopup(
            context,
            [
              (String text) {
                intensity = double.tryParse(text) ?? 0;
                lastFireSetup[currentPlayer][0] = intensity;
              },
              (String text) {
                angle = double.tryParse(text) ?? 0;
                setState(() {
                  lastFireSetup[currentPlayer][1] = angle;
                });
              },
            ],
            dataTitle: globals.shootOptions,
            title: globals.shootSetup,
            data: fireSetupString,
            numericData: [true, true],
            barrierDismissable: false, onFinish: (bool confirm) {
          //code after player finished
          setState(() {
            globals.popup = false;
          });
          if (confirm) playerShoot(intensity, angle);
        });

        //move terrain to player
        moveScrollerToRelativePosition(globals.playerPos[currentPlayer]);
      });
    } catch (e) {
      outputError(e);
    }
  }

  void nextPlayer(int playerInt) {
    try {
      //next player
      playerInt++;

      //check for overflow
      if (playerInt == playerTeams.length) {
        playerInt = 0;
      }

      movedPlayer = false;
      currentPlayer = playerInt;
      thisPlayer = widget.type.showPlayerUI(playerInt) ? playerInt : thisPlayer;
    } catch (e) {
      outputError(e);
    }
  }

  void gameResume() async {
    try {
      setState(() {
        loaded = false;
      });

      //resume data
      globals.playerPos =
          await UI.dataLoad(globals.keyPlayerPos, "List<List<double>>");
      globals.playerHealth =
          await UI.dataLoad(globals.keyPlayerHealth, "List<double>");
      globals.mapNo = await UI.dataLoad(globals.keyMapNo, "int");
      amountOfPlayers = await UI.dataLoad(globals.keyAmountOfPlayers, "int");
      currentPlayer = await UI.dataLoad(globals.keyCurrentPlayer, "int");
      thisPlayer = await UI.dataLoad(globals.keyThisPlayer, "int");
      globals.currentMap =
          await UI.dataLoad(globals.keyGameMap, "List<double>");
      lastFireSetup =
          await UI.dataLoad(globals.keyLastFireSetup, "List<List<double>>");
      playerTeams = widget.playerTeams;
      movedPlayer = await UI.dataLoad(globals.keyMovedPlayer, "bool");

      //not start
      startOfGame = false;
      globals.popup = false;

      //rerender with new setup
      setState(() {
        loaded = true;
      });
    } catch (e) {
      outputError(e);
    }
  }

  void gameStart() {
    try {
      // get data from root
      currentPlayer = widget.type.playerNumber;
      playerTeams = widget.playerTeams;
      thisPlayer = currentPlayer;
      globals.mapNo = widget.mapNo;
      globals.currentMap = globals.terrainMaps[widget.mapNo];

      //not start anymore
      startOfGame = false;

      //set amount of players
      amountOfPlayers = playerTeams.length;

      //reset health and fire setups
      globals.playerHealth = List.empty(growable: true);
      lastFireSetup = List.empty(growable: true);
      for (int i = 0; i < amountOfPlayers; i++) {
        globals.playerHealth.add(globals.defaultPlayerHealth);
        lastFireSetup.add(globals.defaultFireSetup.toList());
      }

      //cancel popup
      globals.popup = false;
    } catch (e) {
      outputError(e);
    }
  }

  void moveScroller(double increase) {
    try {
      double currentPos = globals.gameScroller.offset;
      double newPos = currentPos + increase;
      double maxPos = UI.screenWidth(context) * zoom * 0.5;
      newPos = newPos >= 0
          ? newPos < maxPos
              ? newPos
              : maxPos
          : 0;
      globals.gameScroller.animateTo(newPos,
          duration: Duration(milliseconds: 5), curve: Curves.ease);
    } catch (e) {
      outputError(e);
    }
  }

  void quitWithSaving() async {
    try {
      //show saving popup
      setState(() {
        UI.textDisplayPopup(context, globals.saving);
      });

      //save the variables
      try {
        await UI.dataStore(globals.keySavedGame, true);
        await UI.dataStore(globals.keyPlayerPos, globals.playerPos);
        await UI.dataStore(globals.keyPlayerHealth, globals.playerHealth);
        await UI.dataStore(globals.keyMapNo, globals.mapNo);
        await UI.dataStore(globals.keyAmountOfPlayers, amountOfPlayers);
        await UI.dataStore(globals.keyCurrentPlayer, currentPlayer);
        await UI.dataStore(globals.keyThisPlayer, thisPlayer);
        await UI.dataStore(globals.keyPlayerTeams, playerTeams);
        await UI.dataStore(globals.keyGameMap, globals.currentMap);
        await UI.dataStore(globals.keyLastFireSetup, lastFireSetup);
        await UI.dataStore(globals.keyGameType, widget.type.string);
        await UI.dataStore(globals.keyMovedPlayer, movedPlayer);
      } on ArgumentError catch (e) {
        if (e.name == "minified") {
          await UI.dataStore(globals.keySavedGame, false);
        } else {
          throw ("One of data being stored is not correct type");
        }
      }
      //close saving popup
      setState(() {
        Navigator.of(context).pop();
      });

      //quit without saving
      UI.startNewPage(context, [], newPage: LauncherPage());
    } catch (e) {
      outputError(e);
    }
  }

  void keyPresses(RawKeyEvent key) {
    try {
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
          if (keyPress == LogicalKeyboardKey.arrowLeft &&
              playersTurn &&
              !movedPlayer) {
            //move left
            playerMove(false);
          }
          if (keyPress == LogicalKeyboardKey.arrowRight &&
              playersTurn &&
              !movedPlayer) {
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
    } catch (e) {
      outputError(e);
    }
  }

  void outputError(dynamic e) {
    String output = globals.errorOccurred + e.toString();
    setState(() {
      UI.textDisplayPopup(context, output,
          style: TextStyle(color: globals.textColor));
    });
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page;
    try {
      if (startOfGame) widget.resumed ? gameResume() : gameStart();
      pageContext = context;
      if (loaded) {
        playersTurn = thisPlayer == currentPlayer;
        Color playerButtonColour =
            globals.teamColors[playerTeams[currentPlayer]] ?? globals.textColor;
        page = UI.scaffoldWithBackground(children: [
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
                    /*onPanUpdate: (details) {},
                  onPanStart: (details) {},
                  onPanDown: (details) {},
                  onPanEnd: (details) {}, //TODO continue drag stuff
                  onPanCancel: () {},*/
                    child: CustomPaint(
                      size: Size(UI.screenWidth(context) * zoom,
                          UI.screenHeight(context)),
                      painter: GamePainter(
                          currentPlayer, playerTeams, lastFireSetup),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                UI.halfButton(
                                    text: globals.quitWithSave,
                                    onTap: quitWithSaving,
                                    context: context),
                              ],
                            ),
                            Container(
                              height: UI.getPaddingSize(context),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                UI.halfButton(
                                    icon: globals.playAudio
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    onTap: () {
                                      setState(() {
                                        globals.playAudio = !globals.playAudio;
                                        UI.dataStore(globals.keyVolume,
                                            globals.playAudio);
                                      });
                                    },
                                    context: context,
                                    quaterButton: true),
                                Container(width: UI.getPaddingSize(context)),
                                UI.halfButton(
                                    icon: globals.playMusic
                                        ? Icons.music_note_rounded
                                        : Icons.music_off_rounded,
                                    onTap: () {
                                      setState(() {
                                        globals.playMusic = !globals.playMusic;
                                        UI.dataStore(globals.keyMusic,
                                            globals.playMusic);
                                      });
                                    },
                                    context: context,
                                    quaterButton: true),
                              ],
                            ),
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
                          icon: Icon(
                              paused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: globals.textColor),
                          iconSize: globals.iconSize,
                          onPressed: () {
                            pausePress();
                          }),
                    )
                  : Container(),
              //player arrow and shoot buttons
              playersTurn && !globals.popup && !movedPlayer
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
                          Icons.bubble_chart_rounded,
                          color: playerButtonColour,
                        ),
                        iconSize: globals.iconSize,
                        onPressed: () => playerShootTap(),
                      ),
                    )
                  : Container(),
              playersTurn && !globals.popup && !movedPlayer
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
      } else {
        page = UI.scaffoldWithBackground(children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: UI.screenHeight(context) * 0.9,
              ),
              Text(
                globals.loading,
                style: UI.defaultText(true),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ], context: context);
      }
    } catch (e) {
      if (page == null) {
        page = UI.scaffoldWithBackground(children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: UI.screenHeight(context) * 0.9,
              ),
              Text(
                globals.errorOccurred + e.toString(),
                style: UI.defaultText(true),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ], context: context);
      }
      print("Erorr: $e");
    }
    return page;
  }
}
