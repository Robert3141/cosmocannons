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
  LauncherPage({Key key, this.title, this.winner = -1}) : super(key: key);

  final String title;
  final int winner;

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
    // TODO: add as strings
    if (widget.winner != -1) {
      if (widget.winner == -2) {
        _versionString = "No players survived!";
      } else {
        _versionString =
            "The winner is player ${widget.winner + 1} from team ${globals.defaultTeamNames[globals.playerTeams[widget.winner]]}";
      }
    } else {
      _versionString = "Welcome back";
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
