import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

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
  bool firstBuild = true;
  List<int> playerTeams = globals.playerTeams;

  //functions
  void changePlayerTeam(int playerNo, int newTeam) {
    setState(() {
      playerTeams[playerNo - 1] = newTeam;
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
                      text: globals.hostStartServer,
                      onTap: null,
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
                  onTap: null,
                  context: context)
            ],
          ),
          UI.playerTeamsTable(context: context, playerNames: globals.playerNames, playerTeams: globals.playerTeams, changePlayerTeam: changePlayerTeam),
        ],
      ),
    ], context: context, backgroundNo: 3);

    firstBuild = false;

    return page;
  }
}
