import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/Multiplayer/Local/multiplayerlocal.dart';
import 'package:cosmocannons/UI/Multiplayer/LAN/multiplayerclient.dart';
import 'package:cosmocannons/UI/Multiplayer/LAN/multiplayerhost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiplayerPage extends StatefulWidget {
  //constructor of the class
  MultiplayerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MultiplayerPageState createState() => _MultiplayerPageState();
}

class _MultiplayerPageState extends State<MultiplayerPage> {
  //locals

  //functions
  void localMutli() {
    UI.gotoNewPage(context, LocalMultiPage());
  }

  void hostMutli() {
    UI.gotoNewPage(context, HostMultiPage());
  }

  void clientMulti() {
    UI.gotoNewPage(context, ClientMultiPage());
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(
      context: context,
      backgroundNo: 2,
      children: [
        UI.topTitle(
            titleText: globals.multiplayer, context: context, root: false),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UI.largeButton(
                height: UI.getHalfHeight(context) * globals.heightMultiplier,
                text: globals.localMulti,
                onTap: () => localMutli(),
                context: context),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UI.largeButton(
                    height: UI.getHalfHeight(context) *
                        globals.halfButton *
                        globals.heightMultiplier,
                    text: globals.hostMulti,
                    onTap: () => hostMutli(),
                    context: context),
                Container(height: UI.getPaddingSize(context)),
                UI.largeButton(
                    height: UI.getHalfHeight(context) *
                        globals.halfButton *
                        globals.heightMultiplier,
                    text: globals.clientMulti,
                    onTap: () => clientMulti(),
                    context: context),
              ],
            ),
          ],
        ),
      ],
    );

    return page;
  }
}
