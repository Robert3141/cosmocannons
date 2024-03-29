import 'package:cosmocannons/UI/introPage.dart';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  //constructor of class
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //build UI
  @override
  Widget build(BuildContext context) {
    var page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.settings,
          context: context,
          helpText: globals.helpSettings),
      Container(
        height: globals.paddingSize * UI.screenHeight(context),
      ),
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
                //TUTORIAL
                UI.settingsButton(
                    'Run Intro Guide',
                    () => UI.startNewPage(context, [], newPage: IntroPage()),
                    context),
                Container(
                  height: UI.getPaddingSize(context),
                ),
                //REST
                UI.settingsButton(
                    'Reset Entire App',
                    () => UI.dataInputPopup(context, [null],
                            notInput: true,
                            data: [
                              'Are you sure you want to reset the entire app. All the achievements and settings will be reset.'
                            ], onFinish: (bool b) async {
                          if (b) {
                            var prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            UI.startNewPage(context, [],
                                newPage: LauncherPage());
                          }
                        }),
                    context)
              ],
            ),
          ),
        ],
      ),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
