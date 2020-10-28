import 'package:cosmocannons/UI/Multiplayer/multiplayer.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/Achievements/achievements.dart';
import 'package:cosmocannons/UI/Settings/settings.dart';
import 'package:cosmocannons/UI/Singleplayer/singleplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LauncherPage extends StatefulWidget {
  //constructor of the class
  LauncherPage({Key key, this.title, this.winner = -1, this.playerTeams})
      : super(key: key);

  final String title;
  final int winner;
  final List<int> playerTeams;

  @override
  _LauncherPageState createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  //locals
  bool firstBuild = true;
  int amountOfPlays = 0;
  String _versionString = "Loading . . .";

  //functions

  void singlePlayer() {
    UI.gotoNewPage(context, SingleplayerPage());
  }

  void multiplayer() {
    UI.gotoNewPage(context, MultiplayerPage());
  }

  void settings() {
    UI.gotoNewPage(context, SettingsPage());
  }

  void achievements() {
    UI.gotoNewPage(context, AchievementsPage());
  }

  void showWinningPopup() {
    //check not null
    if (widget.winner != -1) {
      if (widget.winner == -2) {
        _versionString = globals.allDead;
      } else {
        _versionString = globals.winningPlayerIs[0];
        _versionString += (widget.winner + 1).toString();
        _versionString += globals.winningPlayerIs[1];
        _versionString +=
            globals.defaultTeamNames[widget.playerTeams[widget.winner]];
      }
    } else {
      _versionString = globals.welcomeBack;
    }
  }

  void loadVariables() async {
    globals.playAudio =
        await UI.dataLoad(globals.keyVolume, bool) ?? globals.playAudio;
    globals.playMusic =
        await UI.dataLoad(globals.keyMusic, bool) ?? globals.playMusic;
  }

  void firstBuilder() {
    if (firstBuild) {
      firstBuild = false;
      showWinningPopup();
      loadVariables();
      //getVersionString();
    }
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    firstBuilder();
    Scaffold page = UI.scaffoldWithBackground(context: context, children: [
      UI.topTitle(titleText: globals.gameTitle, context: context, root: true),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UI.largeButton(
              enabled: false, // TODO: make singleplayer mode
              text: globals.singleplayer,
              onTap: () => singlePlayer(),
              context: context),
          UI.largeButton(
              text: globals.multiplayer,
              onTap: () => multiplayer(),
              context: context),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UI.smallButton(
              text: globals.settings,
              onTap: () => settings(),
              context: context),
          UI.textWidget(_versionString),
          UI.smallButton(
              text: globals.achievements,
              onTap: () => achievements(),
              enabled: false,
              context: context),
        ],
      ),
    ]);

    return page;
  }
}
