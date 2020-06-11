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
  LauncherPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LauncherPageState createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  //locals

  //functions
  void singlePlayer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SingleplayerPage()));
  }

  void multiplayer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MultiplayerPage()));
  }

  void settings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  void achievements() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AchievementsPage()));
  }

  bool firstBuild = true;
  String _versionString = "Loading . . .";
  Future getVersionString() async {
    if (firstBuild) {
      firstBuild = false;
      if (kIsWeb) {
        setState(() {
          _versionString = "Plays: 0";
        });
      } else {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        //String versionName = packageInfo.version;
        String versionCode = packageInfo.buildNumber;
        String fullString =
            "Version no: $versionCode Plays: 0"; //TODO add no. of plays
        setState(() {
          _versionString = fullString;
        });
      }
    }
  }

  //build UI
  @override
  Widget build(BuildContext context) {
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
          Text(
            _versionString,
            style: UI.defaultText(false),
          ),
          UI.smallButton(
              text: globals.achievements,
              onTap: () => achievements(),
              context: context),
        ],
      ),
    ]);

    getVersionString();

    return page;
  }
}
