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
  List<int> playerTeams = globals.playerTeams;
  String userNameText = "";
  ServerNode server;

  //functions
  void playerNameChange(String text) {
    setState(() {
      //update player name
      userNameText = text;
      globals.playerNames[0] = text;
    });
  }

  void nameSelectPopup() {
    setState(() {
      UI.dataInputPopup(context, playerNameChange);
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
      //serverStatus = "Server ready on ${server.host}:${server.port}";
    });
    server.dataResponse.listen(dataReceived);
  }

  void dataReceived(DataPacket data) {}

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

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: globals.hostMulti, context: context),
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
                      text: globals.hostName,
                      onTap: nameSelectPopup,
                      enabled: !hostingServer,
                      context: context),
                  Container(
                    width: UI.getPaddingSize(context),
                  ),
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * globals.halfButton,
                      height: UI.getHalfHeight(context) *
                          globals.halfButton *
                          globals.heightMultiplier,
                      text: globals.hostStartServer,
                      onTap: null,
                      enabled: userNameText.isNotEmpty,
                      context: context)
                ],
              ),
              Container(
                height: UI.getPaddingSize(context),
              ),
              UI.largeButton(
                width: UI.getHalfWidth(context),
                height: UI.getHalfHeight(context) *
                    globals.halfButton *
                    globals.heightMultiplier,
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
              playerNames: globals.playerNames,
              playerTeams: globals.playerTeams,
              changePlayerTeam: changePlayerTeam),
        ],
      ),
    ], context: context, backgroundNo: 3);

    return page;
  }
}
