import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

class SingleplayerPage extends StatefulWidget {
  //constructor of class
  SingleplayerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SingleplayerPageState createState() => _SingleplayerPageState();
}

class _SingleplayerPageState extends State<SingleplayerPage> {
  //locals

  //functions
  void amountOfPlayersChange(int i) {
    setState(() {
      globals.playerNum = i + 2;
    });
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: globals.singleplayer, context: context),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: UI.getHalfHeight(context) *
                globals.halfButton *
                UI.screenHeight(context),
            width: UI.screenWidth(context),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UI.textWidget(globals.amountOfPlayers, spacing: TextAlign.end),
                UI.optionToggle(
                  items: globals.playerAmounts,
                  selectedInt: globals.playerNum - 2,
                  onTap: amountOfPlayersChange,
                  context: context,
                ),
              ],
            ),
          ),
          Container(
            height: 3 * UI.getPaddingSize(context),
          ),
          UI.largeButton(
              height: UI.getHalfHeight(context) *
                  globals.halfButton *
                  globals.heightMultiplier,
              width: UI.getHalfWidth(context),
              text: "null",
              onTap: () {},
              context: context)
        ],
      ),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
