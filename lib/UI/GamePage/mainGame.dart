import 'dart:async';
import 'dart:ui';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:cosmocannons/UI/GamePage/pageControls.dart';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:flutter/services.dart';
import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:cosmocannons/overrides.dart';

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
  bool startOfGame = true;
  bool paused = false;
  bool playersTurn = true;
  bool loaded = true;
  bool movedPlayer = false;
  BuildContext pageContext;
  TapDownDetails tapDetails;
  String updaterText = "";

  ///
  /// FUNCTIONS
  ///

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

  Future<void> loadPlayerData() async {
    try {
      //save data
      List<double> aX =
          await UI.dataLoad(globals.keyPlayerPosX, "List<double>");
      List<double> aY =
          await UI.dataLoad(globals.keyPlayerPosY, "List<double>");
      List<double> health =
          await UI.dataLoad(globals.keyPlayerHealth, "List<double>");
      List<int> team = await UI.dataLoad(globals.keyPlayerTeams, "List<int>");
      //loop through
      globals.players = List.empty(growable: true);
      for (int i = 0; i < aX.length; i++)
        globals.players.add(Player.withHealth(
            Offset(aX[i], aY[i]), team[i], health[i], updateUI, context));
    } catch (e) {
      print(e.toString());
    }
  }

  void gameResume() async {
    try {
      setState(() {
        loaded = false;
      });

      //resume data
      globals.mapNo = await UI.dataLoad(globals.keyMapNo, "int");
      globals.currentPlayer =
          await UI.dataLoad(globals.keyCurrentPlayer, "int");
      globals.thisPlayer = await UI.dataLoad(globals.keyThisPlayer, "int");
      globals.currentMap =
          await UI.dataLoad(globals.keyGameMap, "List<double>");

      //load players
      await loadPlayerData();

      //not start
      startOfGame = false;
      globals.popup = false;

      //play music
      UI.playMusic();

      //rerender with new setup
      setState(() {
        loaded = true;
      });

      //singleplayer play AI of current player
      if (globals.type == globals.GameType.singlePlayer &&
          globals.currentPlayer != 0)
        globals.players[globals.currentPlayer]
            .playAI(updateUI, globals.currentPlayer);
    } catch (e) {
      print(e.toString());
      //outputError(e);
    }
  }

  void gameStart() async {
    try {
      // get data from root
      globals.currentPlayer = 0;
      globals.thisPlayer = globals.type.playerNumber;
      globals.mapNo = widget.mapNo;
      globals.currentMap = globals.terrainMaps[widget.mapNo];

      //not start anymore
      startOfGame = false;

      //create players
      globals.players = List.empty(growable: true);
      for (int i = 0; i < widget.playerTeams.length; i++)
        globals.players.add(Player.fromListCreated(i, widget.playerTeams.length,
            widget.playerTeams[i], globals.currentMap, updateUI, context));

      //play music
      UI.playMusic();

      //cancel popup
      globals.popup = false;

      //set data receivers
      if (globals.type == globals.GameType.multiHost)
        globals.server.dataResponse.listen(dataReceiver);
      if (globals.type == globals.GameType.multiClient)
        globals.client.dataResponse.listen(dataReceiver);
    } catch (e) {
      outputError(e);
    }
  }

  void moveScroller(double increase) {
    try {
      double currentPos = globals.gameScroller.offset;
      double newPos = currentPos + increase;
      globals.gameScroller.animateTo(newPos,
          duration: Duration(milliseconds: 100), curve: Curves.ease);
    } catch (e) {
      outputError(e);
    }
  }

  Future<bool> savePlayerData(List<Player> playerData) async {
    //locals
    bool savedCorrectly = true;
    int length = globals.players.length;

    //save data
    savedCorrectly &= await UI.dataStore(globals.keyPlayerPosX,
        List<double>.generate(length, (index) => playerData[index].aX));
    savedCorrectly &= await UI.dataStore(globals.keyPlayerPosY,
        List<double>.generate(length, (index) => playerData[index].aY));
    savedCorrectly &= await UI.dataStore(globals.keyPlayerHealth,
        List<double>.generate(length, (index) => playerData[index].health));
    savedCorrectly &= await UI.dataStore(globals.keyPlayerTeams,
        List<int>.generate(length, (index) => playerData[index].team));

    return savedCorrectly;
  }

  void quitNoSave() async {
    //stop music
    await UI.stopMusic();

    //dispose LAN
    if (globals.type == globals.GameType.multiHost) globals.server.disposer();
    if (globals.type == globals.GameType.multiClient) globals.client.disposer();

    //disable pause menu
    globals.popup = false;

    //quit without saving
    UI.startNewPage(context, [], newPage: LauncherPage());
  }

  void quitWithSaving() async {
    bool savedCorrectly = true;
    try {
      //show saving popup
      setState(() {
        UI.textDisplayPopup(context, globals.saving);
      });

      if (globals.players.length > 1) {
        //save the variables
        try {
          //save variables
          savedCorrectly &= await UI.dataStore(globals.keyMapNo, globals.mapNo);
          savedCorrectly &= await UI.dataStore(
              globals.keyCurrentPlayer, globals.currentPlayer);
          savedCorrectly &=
              await UI.dataStore(globals.keyThisPlayer, globals.thisPlayer);
          savedCorrectly &=
              await UI.dataStore(globals.keyGameMap, globals.currentMap);
          savedCorrectly &=
              await UI.dataStore(globals.keyGameType, widget.type.string);
          savedCorrectly &=
              await UI.dataStore(globals.keyMovedPlayer, movedPlayer);
          //save objects
          savedCorrectly &= await savePlayerData(globals.players);
          // only report as saved if saving worked
          await UI.dataStore(globals.keySavedGame, savedCorrectly);
        } on ArgumentError catch (e) {
          if (e.name == "minified") {
            await UI.dataStore(globals.keySavedGame, false);
          } else {
            print("$e");
            throw ("One of data being stored is not correct type");
          }
        }
      } else {
        //only 1 or fewer players
        await UI.dataStore(globals.keySavedGame, false);
      }

      //stop music
      await UI.stopMusic();

      //disable pause menu
      globals.popup = false;

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
        if (!paused & !globals.firing) {
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
            globals.players[globals.currentPlayer].moveLeft();
          }
          if (keyPress == LogicalKeyboardKey.arrowRight &&
              playersTurn &&
              !movedPlayer) {
            //move right
            globals.players[globals.currentPlayer].moveRight();
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

  void updateUI() {
    //mounted ensures this only updates UI if dispose hasn't been called
    if (mounted)
      setState(() {
        updaterText = updaterText == "" ? " " : "";
      });
  }

  /// Receives data from the server/client
  void dataReceiver(DataPacket data) async {
    switch (data.title) {
      case globals.packetFire:
        //prevents repeat packets from firing two projectiles
        if (!globals.firing) {
          globals.firing = true;
          if (globals.type == globals.GameType.multiHost) {
            // Server
            globals.server.sendToEveryone(
                globals.packetFire, data.payload, globals.players.length);
          }
          //render firing
          globals.projectiles.add(Projectile.velocity(
              data.payload.toString().parseOffset(),
              globals.currentPlayer,
              updateUI));
        }
        break;
      case globals.packetPlayersTurn:
        while (globals.firing) {
          await Future.delayed(Duration(milliseconds: 100));
        }
        setState(() {
          globals.currentPlayer = int.parse(data.payload.toString());
        });
        break;
      case globals.packetGameEnd:
        if (globals.type == globals.GameType.multiHost) {
          //server forward to others
          globals.server.disposer();
        } else {
          //client dispose
          globals.client.dispose();
        }
        //stop music
        await UI.stopMusic();

        //disable pause menu
        globals.popup = false;

        //quit without saving
        UI.startNewPage(context, [], newPage: LauncherPage());
        break;
      default:
        debugPrint("Error packet not known title");
        debugPrint("$data");
        break;
    }
  }

  void outputError(dynamic e) {
    String output = globals.errorOccurred + e.toString();
    setState(() {
      UI.textDisplayPopup(context, output,
          style: TextStyle(color: globals.textColor));
    });
  }

  @override
  void dispose() {
    //stop music
    UI.stopMusic();

    //dispose UI
    super.dispose();
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page;
    try {
      if (startOfGame) {
        globals.type = widget.type;
        widget.resumed ? gameResume() : gameStart();
      }
      pageContext = context;
      if (loaded) {
        playersTurn = globals.thisPlayer == globals.currentPlayer;
        Color playerButtonColour =
            globals.players[globals.currentPlayer].teamColour ??
                globals.textColor;
        double sWidth = UI.screenWidth(context);
        double sHeight = UI.screenHeight(context);
        zoom = (16 * sHeight) / (9 * sWidth);
        if (zoom < 1) zoom = 1;
        globals.canvasSize =
            Size(UI.screenWidth(context) * zoom, UI.screenHeight(context));
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
                  child: RawGestureDetector(
                    gestures: <Type, GestureRecognizerFactory>{
                      CustomGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                                  CustomGestureRecognizer>(
                              () => CustomGestureRecognizer(updateUI, zoom),
                              (CustomGestureRecognizer instance) {})
                    },
                    child: Stack(
                      children: [
                        //projectiles
                        CustomPaint(
                          willChange:
                              globals.firing || (globals.dragGhost ?? false),
                          size: globals.canvasSize,
                          painter: ShootPainter(),
                          child: Text(updaterText),
                        ),

                        //terrain
                        CustomPaint(
                          isComplex: true,
                          size: globals.canvasSize,
                          painter: GamePainter(),
                        ),
                        //players
                        CustomPaint(
                          size: globals.canvasSize,
                          painter: CharacterPainter(),
                        ),
                      ],
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
                                    text: globals.type.isLAN
                                        ? globals.quitNoSave
                                        : globals.quitWithSave,
                                    onTap: globals.type.isLAN
                                        ? quitNoSave
                                        : quitWithSaving,
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
                                        globals.playMusic
                                            ? UI.playMusic()
                                            : UI.stopMusic();
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
              (globals.popup && paused) || (!globals.popup & !globals.firing)
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
                        onPressed: () =>
                            globals.players[globals.currentPlayer].moveLeft(),
                      ),
                    )
                  : Container(),
              /*playersTurn && !globals.popup
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
                  : Container(),*/
              playersTurn && !globals.popup && !movedPlayer
                  ? Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded,
                            color: playerButtonColour),
                        iconSize: globals.iconSize,
                        onPressed: () =>
                            globals.players[globals.currentPlayer].moveRight(),
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
