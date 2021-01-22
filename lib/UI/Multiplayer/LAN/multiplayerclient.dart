import 'package:client_server_lan/client_server_lan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:wifi/wifi.dart';
import 'package:cosmocannons/overrides.dart';

class ClientMultiPage extends StatefulWidget {
  //constructor of class
  ClientMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ClientMultiPageState createState() => _ClientMultiPageState();
}

class _ClientMultiPageState extends State<ClientMultiPage> {
  //locals
  bool readyForPlay = false;
  bool connectedToServer = false;
  bool connecting = false;
  int playerNumber = 1;
  List<int> playerTeams = List.from(globals.playerTeams);
  List<String> playerNames = List.from(globals.playerNames);
  List<bool> playerConnected = List.filled(4, false);
  String userNameText = "";
  ClientNode client;

  //functions
  void playerNameChange(String text) {
    setState(() {
      //update player name
      userNameText = text;
      playerNames[1] = text;
    });
  }

  void nameSelectPopup() {
    setState(() {
      UI.dataInputPopup(context, [playerNameChange], title: globals.hostName);
    });
  }

  void startClient() async {
    setState(() {
      connecting = true;
    });
    String ip = await Wifi.ip;
    client = ClientNode(
      name: userNameText,
      verbose: true,
      host: ip,
      port: 8085,
    );
    await client.init();
    await client.onReady;
    //server now ready
    setState(() {
      //serverStatus = "Server ready on ${server.host}:${server.port}";
    });
    //pass data
    globals.dataReceiver = client.dataResponse;
    client.dataResponse.listen(dataReceived);
  }

  void dataReceived(DataPacket data) {
    switch (data.title) {
      case globals.packetPlayerNumber:
        playerNumber = int.parse(data.payload) + 2;
        setState(() {
          connecting = false;
          connectedToServer = true;
        });
        break;
      case globals.packetPlayerNames:
        setState(() {
          playerNames = data.payload.toString().parseListString();
        });
        break;
      case globals.packetPlayerEnabled:
        setState(() {
          playerConnected = data.payload.toString().parseListBool();
        });
        break;
      case globals.packetPlayerTeams:
        setState(() {
          playerTeams = data.payload.toString().parseListInt();
        });
        break;
      default:
        debugPrint("Error packet not known title");
        debugPrint("$data");
        break;
    }
  }

  void changePlayerTeam(int playerNo, int newTeam) {
    print(playerNumber);
    if (playerNo == playerNumber) {
      setState(() {
        playerTeams[playerNo - 1] = newTeam;
      });
      client.sendData(
          globals.packetPlayerTeams, playerTeams, client.serverDetails.address);
    }
  }

  void toggleReady() {
    setState(() {
      readyForPlay = !readyForPlay;
      client.sendData(globals.packetPlayerReady, readyForPlay,
          client.serverDetails.address);
    });
  }

  @override
  void dispose() {
    if (client != null) if (client.isRunning) client.dispose();
    super.dispose();
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.clientMulti,
          context: context,
          helpText: globals.helpMultiplayerClient),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * globals.halfButton,
                      height: UI.getHalfHeight(context) *
                          globals.halfButton *
                          globals.heightMultiplier,
                      text: globals.clientName,
                      onTap: nameSelectPopup,
                      enabled: !connectedToServer && !connecting,
                      context: context),
                  Container(
                    width: UI.getPaddingSize(context),
                  ),
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * globals.halfButton,
                      height: UI.getHalfHeight(context) *
                          globals.halfButton *
                          globals.heightMultiplier,
                      text: globals.clientConnectServer,
                      enabled: userNameText.isNotEmpty &&
                          !connectedToServer &&
                          !connecting,
                      onTap: startClient,
                      context: context),
                ],
              ),
              Container(
                height: UI.getPaddingSize(context),
              ),
              UI.halfButton(
                  text: readyForPlay ? globals.readyForPlay : globals.readyUp,
                  onTap: () => toggleReady(),
                  enabled: connectedToServer,
                  buttonFill: readyForPlay
                      ? globals.buttonReady
                      : globals.buttonNotReady,
                  context: context),
            ],
          ),
          UI.playerTeamsTable(
              context: context,
              playerNames: playerNames,
              playerTeams: playerTeams,
              playerEnabled: playerConnected,
              changePlayerTeam: changePlayerTeam)
        ],
      ),
    ], context: context, backgroundNo: 3);

    return page;
  }
}
