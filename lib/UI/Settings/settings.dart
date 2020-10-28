import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

class SettingsPage extends StatefulWidget {
  //constructor of class
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //locals

  //functions

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: globals.settings, context: context),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: globals.halfButton *
                globals.heightMultiplier *
                UI.screenHeight(context),
            width: UI.screenWidth(context) - 2 * UI.getPaddingSize(context),
            child: ListView(
              children: [
                //VOLUME
                UI.settingsEntry(
                    globals.keyVolume,
                    [Icons.volume_off_rounded, Icons.volume_up_rounded],
                    globals.playAudio, (int i) {
                  setState(() {
                    globals.playAudio = i == 1;
                    UI.dataStore(globals.keyVolume, globals.playAudio);
                  });
                }, context),
                Container(
                  height: UI.getPaddingSize(context),
                ),
                //MUSIC
                UI.settingsEntry(
                    globals.keyMusic,
                    [Icons.music_off_rounded, Icons.music_note_rounded],
                    globals.playMusic, (int i) {
                  setState(() {
                    globals.playMusic = i == 1;
                    UI.dataStore(globals.keyMusic, globals.playMusic);
                  });
                }, context),
              ],
            ),
          ),
        ],
      ),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
