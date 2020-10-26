import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

class LocalMultiPage extends StatefulWidget {
  //constructor of class
  LocalMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocalMultiPageState createState() => _LocalMultiPageState();
}

class _LocalMultiPageState extends State<LocalMultiPage> {
  //locals
  int amountOfPlayers = globals.defualtPlayerAmount;

  //functions
  void beginGame() {
    //add players to player teams
    globals.playerTeams = List.empty(growable: true);
    for (int i = 0; i < amountOfPlayers; i++) {
      globals.playerTeams.add(i);
    }
    UI.startNewPage(context);
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: globals.localMulti, context: context),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UI.optionToggle(
                  title: globals.amountOfPlayers,
                  selectedInt: amountOfPlayers - 2,
                  items: globals.playerAmounts,
                  onTap: (int selected) {
                    setState(() {
                      amountOfPlayers = selected + 2;
                    });
                  },
                  context: context),
              UI.optionToggle(
                  title: "test",
                  items: ["yes", "no"],
                  onTap: (int selected) {},
                  context: context),
            ],
          ),
          Container(
            height: UI.getPaddingSize(context),
          ),
          UI.halfButton(
              text: globals.beginGame, onTap: beginGame, context: context),
        ],
      ),
    ], context: context, backgroundNo: 3);

    return page;
  }
}
