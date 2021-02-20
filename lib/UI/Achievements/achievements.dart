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

  //functions

  //build UI
  @override
  Widget build(BuildContext context) {
    var page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.achievements,
          context: context,
          helpText: globals.helpAchievements),
      Row(),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
