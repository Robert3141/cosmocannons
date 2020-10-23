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
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UI.textWidget("test"),
                      UI.optionToggle(
                        heightMultiplier: 0.5,
                        items: ["yes", "no", "maybe"],
                        onTap: (int i) {},
                        context: context,
                      )
                    ],
                  ),
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
