import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';

class ClientMultiPage extends StatefulWidget {
  //constructor of class
  ClientMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ClientMultiPageState createState() => _ClientMultiPageState();
}

class _ClientMultiPageState extends State<ClientMultiPage> {
  //locals

  //functions

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: Strings.clientMulti, context: context),
      Row(),
    ], context: context, backgroundNo: 3);

    return page;
  }
}