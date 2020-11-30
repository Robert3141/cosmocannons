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

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(
          titleText: globals.singleplayer,
          context: context,
          helpText: globals.helpSinglePlayer),
    ], context: context, backgroundNo: 2);

    return page;
  }
}
