import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

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
  List<int> playerTeams = globals.playerTeams;

  //functions
  void toggleReady() {
    setState(() {
      readyForPlay = !readyForPlay;
    });
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: globals.clientMulti, context: context),
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
                      onTap: null,
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
                      onTap: null,
                      context: context),
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
                  enabled: connectedToServer,
                  buttonFill: readyForPlay
                      ? globals.buttonReady
                      : globals.buttonNotReady,
                  context: context),
            ],
          ),
          UI.playerTeamsTable(
              context: context,
              playerNames: globals.playerNames,
              playerTeams: globals.playerTeams,
              changePlayerTeam: null)
        ],
      ),
    ], context: context, backgroundNo: 3);

    return page;
  }
}
