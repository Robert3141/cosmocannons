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
  int mapSelected = globals.defaultMap;
  //functions
  void checkStartGame() async {
    //check save
    bool savedGame = await UI.dataLoad(globals.keySavedGame, 'bool') ?? false;

    if (savedGame) {
      setState(() {
        UI.dataInputPopup(context, [null],
            notInput: true,
            data: [globals.warningMapOverwrite], onFinish: (bool b) {
          if (b) beginGame();
        });
      });
    } else {
      beginGame();
    }
  }

  void beginGame() {
    // add players to list
    var playerTeams = List<int>.empty(growable: true);
    for (var i = 0; i < amountOfPlayers; i++) {
      playerTeams.add(i);
    }
    UI.startNewPage(context, playerTeams, chosenMap: mapSelected);
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    var page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.localMulti,
          context: context,
          helpText: globals.helpMultiplayerLocal),
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
                  title: globals.mapChosen,
                  selectedInt: mapSelected,
                  items: globals.mapNames,
                  onTap: (int selected) {
                    setState(() {
                      mapSelected = selected;
                    });
                  },
                  fillColors: List<Color>.generate(globals.terrainColors.length,
                      (index) => globals.terrainColors[index].last),
                  context: context)
            ],
          ),
          Container(
            height: UI.getPaddingSize(context),
          ),
          UI.halfButton(
              text: globals.beginGame, onTap: checkStartGame, context: context),
        ],
      ),
    ], context: context, backgroundNo: mapSelected + 7);

    return page;
  }
}
