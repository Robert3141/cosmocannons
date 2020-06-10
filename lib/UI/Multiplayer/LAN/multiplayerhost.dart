import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';

class HostMultiPage extends StatefulWidget {
  //constructor of class
  HostMultiPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocalMultiPageState createState() => _LocalMultiPageState();
}

class _LocalMultiPageState extends State<HostMultiPage> {
  //locals
  bool readyForPlay = false;

  //functions

  //build UI
  @override
  Widget build(BuildContext context) {
    Scaffold page = UI.scaffoldWithBackground(children: [
      UI.topTitle(titleText: Strings.hostMulti, context: context),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * Strings.halfButton,
                      height: UI.getHalfHeight(context) *
                          Strings.halfButton *
                          Strings.heightMultiplier,
                      text: Strings.hostName,
                      onTap: null,
                      context: context),
                  Container(
                    width: UI.getPaddingSize(context: context),
                  ),
                  UI.largeButton(
                      width: UI.getHalfWidth(context) * Strings.halfButton,
                      height: UI.getHalfHeight(context) *
                          Strings.halfButton *
                          Strings.heightMultiplier,
                      text: Strings.hostStartServer,
                      onTap: null,
                      context: context)
                ],
              ),
              Container(
                height: UI.getPaddingSize(context: context),
              ),
              UI.largeButton(
                  width: UI.getHalfWidth(context),
                  height: UI.getHalfHeight(context) *
                      Strings.halfButton *
                      Strings.heightMultiplier,
                  text: readyForPlay ? Strings.readyForPlay : Strings.readyUp,
                  onTap: null,
                  context: context)
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: Strings.buttonBorderSize, color: Strings.buttonBorder),
              borderRadius: BorderRadius.circular(Strings.buttonClipSize),
            ),
            width: UI.getHalfWidth(context) * UI.screenWidth(context),
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: Strings.maxLANPlayers + 1,
              itemBuilder: (BuildContext context, int y) {
                return Container(
                  height: UI.getHalfHeight(context) *
                      0.2 *
                      Strings.heightMultiplier *
                      UI.screenHeight(context),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: Strings.maxLANPlayers + 1,
                      itemBuilder: (BuildContext context, int x) {
                        if (x == 0 && y == 0) {
                          return Container(
                            alignment: Alignment.center,
                            width: UI.getHalfWidth(context) *
                                0.2 *
                                UI.screenWidth(context),
                          );
                        } else if (x == 0) {
                          return Container(
                            alignment: Alignment.center,
                            width: UI.getHalfWidth(context) *
                                0.2 *
                                UI.screenWidth(context),
                            child: Text(
                              y == 1 ? Strings.host : Strings.client,
                              style: UI.defaultText(titleText: false),
                            ),
                          );
                        } else if (y == 0) {
                          return Container(
                            alignment: Alignment.center,
                            width: UI.getHalfWidth(context) *
                                0.2 *
                                UI.screenWidth(context),
                            child: Text(
                              Strings.teamNames[x - 1],
                              style: UI.defaultText(titleText: false),
                            ),
                          );
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            width: UI.getHalfWidth(context) *
                                0.2 *
                                UI.screenWidth(context),
                          );
                        }
                      }),
                );
              },
            ),
          ),
        ],
      ),
    ], context: context, backgroundNo: 3);

    return page;
  }
}
