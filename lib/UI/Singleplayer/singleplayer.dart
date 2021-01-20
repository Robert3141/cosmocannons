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
  int amountOfPlayers = globals.defualtPlayerAmount;
  int mapSelected = globals.defaultMap;

  //functions
  void checkStartGame() async {
    //check save
    bool savedGame = await UI.dataLoad(globals.keySavedGame, "bool") ?? false;

    if (savedGame) {
      setState(() {
        UI.dataInputPopup(context, [null],
            notInput: true,
            data: [globals.warningMapOverwrite], onFinish: (bool b) {
          if (b) beginGame();
        });
      });
    }
  }

  void beginGame() {
    // add players to list
    List<int> playerTeams = List.empty(growable: true);
    for (int i = 0; i < amountOfPlayers; i++) {
      playerTeams.add(i);
    }
    UI.startNewPage(context, playerTeams,
        chosenMap: mapSelected, type: globals.GameType.singlePlayer);
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.singleplayer,
          context: context,
          helpText: globals.helpSinglePlayer),
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
