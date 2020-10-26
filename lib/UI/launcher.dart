import 'package:cosmocannons/UI/Multiplayer/multiplayer.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/Achievements/achievements.dart';
import 'package:cosmocannons/UI/Settings/settings.dart';
import 'package:cosmocannons/UI/Singleplayer/singleplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

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

  Future getVersionString() async {
    //detect platform
    var platform = Theme.of(context).platform;
    bool kIsAndroid = platform == TargetPlatform.android;
    bool kIsIOS = platform == TargetPlatform.iOS;
    bool kIsMobile = kIsAndroid || kIsIOS;

    //do platform specific
    if (!kIsMobile) {
      setState(() {
        _versionString = "Plays: $amountOfPlays";
      });
    } else {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //String versionName = packageInfo.version;
      String versionCode = packageInfo.buildNumber;
      String fullString =
          "Version no: $versionCode Plays: $amountOfPlays"; //TODO add no. of plays
      setState(() {
        _versionString = fullString;
      });
    }
  }

  void showWinningPopup() {
    //check not null
    if (widget.winner != -1) {
      setState(() {
        UI.textDisplayPopup(context,
            "The winner is player ${widget.winner} part of team ${globals.teamColors[globals.playerTeams[widget.winner]]}");
      });
    }
  }

  void firstBuilder() {
    if (firstBuild) {
      firstBuild = false;
      showWinningPopup();
      getVersionString();
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
              context: context),
        ],
      ),
    ]);

    return page;
  }
}
