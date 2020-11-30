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
      UI.topTitle(
          titleText: globals.settings,
          context: context,
          helpText: globals.helpSettings),
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
                  (int i) {
                    setState(() {
                      globals.playAudio = i == 1;
                      UI.dataStore(globals.keyVolume, globals.playAudio);
                    });
                  },
                  context,
                  icons: [Icons.volume_off_rounded, Icons.volume_up_rounded],
                  boolVar: globals.playAudio,
                ),
                Container(
                  height: UI.getPaddingSize(context),
                ),
                //MUSIC
                UI.settingsEntry(globals.keyMusic, (int i) {
                  setState(() {
                    globals.playMusic = i == 1;
                    UI.dataStore(globals.keyMusic, globals.playMusic);
                  });
                }, context,
                    icons: [Icons.music_off_rounded, Icons.music_note_rounded],
                    boolVar: globals.playMusic),
                Container(
                  height: UI.getPaddingSize(context),
                ),
                //RENDER HEIGHT
                UI.settingsEntry(globals.keyRenderHeight, (int i) {
                  setState(() {
                    globals.terrainColumnsToRender = globals.mapQualitySizes[i];
                    UI.dataStore(globals.keyRenderHeight,
                        globals.terrainColumnsToRender);
                  });
                }, context,
                    texts: globals.mapQualityString,
                    ints: globals.mapQualitySizes,
                    intVar: globals.terrainColumnsToRender),
                Container(
                  height: UI.getPaddingSize(context),
                ),
              ],
            ),
          ),
        ],
      ),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
