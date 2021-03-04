import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;

class AchievementsPage extends StatefulWidget {
  //constructor of class
  AchievementsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  //locals
  bool firstBuild = true;
  List<bool> achievements = [false];

  //functions
  void getAchievements() async {
    achievements =
        await UI.dataLoad(globals.keyAchievements, 'List<bool>') ?? [false];
    print(achievements);
    setState(() {
      firstBuild = false;
    });
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    if (firstBuild) getAchievements();
    var page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.achievements,
          context: context,
          helpText: globals.helpAchievements),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: globals.halfButton *
                globals.heightMultiplier *
                UI.screenHeight(context),
            width: UI.screenWidth(context) - 2 * UI.getPaddingSize(context),
            child: ListView.builder(
                itemCount: globals.achievementTitles.length,
                itemBuilder: (BuildContext context, int i) =>
                    UI.achievementsEntry(
                        globals.achievementTitles[i],
                        globals.achievementDescription[i],
                        achievements.length > i ? achievements[i] : false,
                        context)),
          )
        ],
      ),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
