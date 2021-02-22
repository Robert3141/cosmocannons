import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:client_server_lan/client_server_lan.dart';
import 'package:cosmocannons/overrides.dart';

class HostMultiPage extends StatefulWidget {
  //constructor of class
  HostMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocalMultiPageState createState() => _LocalMultiPageState();
}

class _LocalMultiPageState extends State<HostMultiPage> {
  //locals
  //bool readyForPlay = false;
  int chosenMap = 0;
  bool hostingServer = false;
  bool scanning = false;
  bool gameStarting = false;
  List<int> playerTeams = List.from(globals.playerTeams);
  List<String> playerNames = List.from(globals.playerNames);
  List<bool> playerConnected = List.filled(4, false);
  List<bool> playerReady = List.filled(4, false);
  String userNameText = '';

  //functions
  void playerNameChange(String text) {
    setState(() {
      //update player name
      userNameText = text;
      playerNames[0] = text;
    });
  }

  void nameSelectPopup() {
    setState(() {
      UI.dataInputPopup(context, [playerNameChange], title: globals.hostName);
    });
  }

  void mapNumberChange(int num) {
    setState(() {
      chosenMap = num;
      Navigator.of(context).pop();
    });
    mapSelectPopup();
    sendToEveryone(globals.packetMapNumber, chosenMap.toString());
  }

  void mapSelectPopup() {
    setState(() {
      UI.dataInputPopup(context, [],
          title: globals.mapChosen,
          child: UI.settingsEntry('', mapNumberChange, context,
              texts: globals.mapNames, ints: [0, 1, 2], intVar: chosenMap),
          numericData: List.filled(globals.mapNames.length, true));
    });
  }

  void startServer() async {
    globals.server = ServerNode(
      name: userNameText,
      verbose: kDebugMode,
    );
    await globals.server.init();
    await globals.server.onReady;
    //server now ready
    setState(() {
      hostingServer = true;
      playerConnected[0] = true;
      //serverStatus = "Server ready on ${server.host}:${server.port}";
    });
    //pass data
    globals.server.dataResponse.listen(dataReceived);
  }

  void scanClients() async {
    setState(() {
      scanning = true;
    });
    await globals.server.discoverNodes();
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    for (var i = 0;
        i < globals.server.clientsConnected.length && i < playerNames.length;
        i++) {
      //update playerNames
      setState(() {
        playerNames[i + 1] = globals.server.clientsConnected[i].name;
        playerConnected[i + 1] = true;
      });
      //tell them their numbers
      await globals.server.sendData(i.toString(), globals.packetPlayerNumber,
          globals.server.clientsConnected[i].address);
    }
    //tell players all the player names
    sendToEveryone(globals.packetPlayerNames, playerNames.toString());
    sendToEveryone(globals.packetPlayerEnabled, playerConnected.toString());
    setState(() {
      scanning = false;
    });
  }

  void dataReceived(DataPacket data) {
    var clientNo = data.clientNo(globals.server);
    if (!gameStarting) {
      if (clientNo != null && clientNo < playerNames.length) {
        //deal with data
        switch (data.title) {
          case globals.packetPlayerReady:
            setState(() {
              playerReady[clientNo + 1] = data.payload == 'true';
              checkgameReadyToStart();
            });
            break;
          case globals.packetPlayerTeams:
            setState(() {
              playerTeams[clientNo + 1] = int.parse(data.payload);
              sendToEveryone(globals.packetPlayerTeams, playerTeams.toString());
            });
            break;
          default:
            debugPrint('Error packet not known title');
            debugPrint('$data');
            break;
        }
      } else {
        //not known player so ignore
        debugPrint('Not known player $clientNo');
        debugPrint('$data');
      }
    }
  }

  void checkgameReadyToStart() {
    if (listEquals(playerReady, playerConnected) &&
        playerConnected[1] == true &&
        !gameStarting) {
      //create players as list only of players that have started
      var players = List<int>.empty(growable: true);
      for (var i = 0; i < playerConnected.length; i++) {
        if (playerConnected[i]) players.add(playerTeams[i]);
      }

      //start game
      print('game starting');
      gameStarting = true;
      sendToEveryone(globals.packetGameStart, gameStarting.toString());
      UI.startNewPage(context, players,
          chosenMap: chosenMap, type: globals.GameType.multiHost);
    }
  }

  void changePlayerTeam(int playerNo, int newTeam) {
    //only change if this player
    if (playerNo == 1) {
      setState(() {
        playerTeams[playerNo - 1] = newTeam;
      });
      //send  updated data
      sendToEveryone(globals.packetPlayerTeams, playerTeams.toString());
    }
  }

  void toggleReady() {
    setState(() {
      playerReady[0] = !playerReady[0];
    });
    checkgameReadyToStart();
  }

  void sendToEveryone(String title, String payload) =>
      globals.server.sendToEveryone(title, payload, playerNames.length);

  @override
  void dispose() {
    if (globals.server != null) {
      if (globals.server.isRunning && !gameStarting) globals.server.dispose();
    }
    super.dispose();
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    var page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.hostMulti,
          context: context,
          helpText: globals.helpMultiplayerHost),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UI.halfButton(
                      quaterButton: true,
                      text:
                          hostingServer ? globals.mapChosen : globals.hostName,
                      onTap: hostingServer ? mapSelectPopup : nameSelectPopup,
                      enabled: true,
                      context: context),
                  Container(
                    width: UI.getPaddingSize(context),
                  ),
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * globals.halfButton,
                      height: UI.getHalfHeight(context) *
                          globals.halfButton *
                          globals.heightMultiplier,
                      text: !hostingServer
                          ? globals.hostStartServer
                          : globals.scanClients,
                      onTap: !hostingServer ? startServer : scanClients,
                      enabled: userNameText.isNotEmpty && !scanning,
                      context: context)
                ],
              ),
              Container(
                height: UI.getPaddingSize(context),
              ),
              UI.halfButton(
                text: playerReady[0] ? globals.readyForPlay : globals.readyUp,
                onTap: () => toggleReady(),
                enabled: hostingServer,
                buttonFill: playerReady[0]
                    ? globals.buttonReady
                    : globals.buttonNotReady,
                context: context,
              )
            ],
          ),
          UI.playerTeamsTable(
              context: context,
              playerNames: playerNames,
              playerTeams: playerTeams,
              playerEnabled: playerConnected,
              changePlayerTeam: changePlayerTeam),
        ],
      ),
    ], context: context, backgroundNo: chosenMap + 7);

    return page;
  }
}
