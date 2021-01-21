import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:client_server_lan/client_server_lan.dart';
import 'package:wifi/wifi.dart';

class HostMultiPage extends StatefulWidget {
  //constructor of class
  HostMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocalMultiPageState createState() => _LocalMultiPageState();
}

class _LocalMultiPageState extends State<HostMultiPage> {
  //locals
  bool readyForPlay = false;
  bool hostingServer = false;
  List<int> playerTeams = List.from(globals.playerTeams);
  List<String> playerNames = List.from(globals.playerNames);
  List<bool> playerConnected = List.filled(4, false);
  String userNameText = "";
  ServerNode server;

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

  void startServer() async {
    String ip = await Wifi.ip;
    server = ServerNode(
      name: "Server",
      verbose: true,
      host: ip,
      port: 8085,
    );
    await server.init();
    await server.onReady;
    //server now ready
    setState(() {
      hostingServer = true;
      playerConnected[0] = true;
      //serverStatus = "Server ready on ${server.host}:${server.port}";
    });
    //pass data
    globals.dataReceiver = server.dataResponse;
    server.dataResponse.listen(dataReceived);
  }

  void scanClients() async {
    server.discoverNodes();
    await Future<dynamic>.delayed(const Duration(seconds: 2));
    for (int i = 0;
        i < server.clientsConnected.length || i < playerNames.length;
        i++) {
      setState(() {
        playerNames[i + 1] = server.clientsConnected[i].name;
        playerConnected[i + 1] = true;
        server.sendData("", data, to)
      });
    }
  }

  void dataReceived(DataPacket data) {
    print(data);
  }

  void changePlayerTeam(int playerNo, int newTeam) {
    setState(() {
      playerTeams[playerNo - 1] = newTeam;
    });
  }

  void toggleReady() {
    setState(() {
      readyForPlay = !readyForPlay;
    });
  }

  @override
  void dispose() {
    if (server != null) if (server.isRunning) server.dispose();
    super.dispose();
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
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
                      text: globals.hostName,
                      onTap: nameSelectPopup,
                      enabled: !hostingServer,
                      context: context),
                  Container(
                    width: UI.getPaddingSize(context),
                  ),
                  UI.halfButton(
                      quaterButton: true,
                      text: hostingServer
                          ? globals.hostStartServer
                          : globals.scanClients,
                      onTap: hostingServer ? startServer : scanClients,
                      enabled: userNameText.isNotEmpty,
                      context: context)
                ],
              ),
              Container(
                height: UI.getPaddingSize(context),
              ),
              UI.halfButton(
                text: readyForPlay ? globals.readyForPlay : globals.readyUp,
                onTap: () => toggleReady(),
                enabled: hostingServer,
                buttonFill:
                    readyForPlay ? globals.buttonReady : globals.buttonNotReady,
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
    ], context: context, backgroundNo: 3);

    return page;
  }
}
