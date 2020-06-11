import 'package:flutter/cupertino.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UI {
  static Size screenSize(context) => MediaQuery.of(context).size;
  static double screenWidth(context) => screenSize(context).width;
  static double screenHeight(context) => screenSize(context).height;

  static TextStyle defaultText(bool titleText) => TextStyle(
        fontFamily: globals.fontName,
        color: globals.textColor,
        fontWeight: FontWeight.bold,
        fontSize: titleText ? globals.largeTextSize : globals.smallTextSize,
      );

  static double getPaddingSize(BuildContext context) {
    double h = UI.screenHeight(context);
    double w = UI.screenWidth(context);
    return h > w ? w * globals.paddingSize : h * globals.paddingSize;
  }

  static double getHalfWidth(BuildContext context) {
    return ((UI.screenWidth(context) - (3 * getPaddingSize(context))) * 0.5) /
        screenWidth(context);
  }

  static double getHalfHeight(BuildContext context) {
    return (((UI.screenHeight(context) /*- globals.largeTextSize */ -
                (2 * getPaddingSize(context))) *
            0.5) /
        UI.screenHeight(context));
  }

  static Scaffold scaffoldWithBackground(
          {@required List<Widget> children,
          @required BuildContext context,
          int backgroundNo = 1}) =>
      Scaffold(
        body: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: globals.backgrounds[backgroundNo - 1],
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(getPaddingSize(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      );

  static Widget topTitle(
          {@required String titleText,
          @required BuildContext context,
          bool root = false}) =>
      Container(
        height: screenHeight(context) * globals.tableElement,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            root
                ? Container()
                : smallButton(
                    text: globals.back,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    context: context,
                  ),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: defaultText(true),
            ),
            root
                ? Container()
                : smallButton(
                    text: globals.help, onTap: null, context: context),
          ],
        ),
      );

  static Widget largeButton(
          {@required String text,
          @required Function onTap,
          double width,
          double height,
          @required BuildContext context}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: screenWidth(context) * (width ?? getHalfWidth(context)),
          height: screenHeight(context) * (height ?? getHalfHeight(context)),
          decoration: BoxDecoration(
              border: Border.all(
                  width: globals.buttonBorderSize, color: globals.buttonBorder),
              borderRadius: BorderRadius.circular(globals.buttonClipSize),
              color: globals.buttonFill),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: defaultText(false),
          ),
        ),
      );

  static Widget smallButton(
          {@required String text,
          @required Function onTap,
          @required BuildContext context}) =>
      largeButton(
          text: text,
          onTap: onTap,
          context: context,
          width: globals.smallWidth,
          height: globals.smallHeight);

  static Widget tableCell(BuildContext context,
          {String text = "",
          Color textColor = globals.textColor,
          bool ticked = false,
          Function onTap}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          color: globals.buttonFill,
          alignment: Alignment.center,
          width: UI.getHalfWidth(context) *
              globals.tableElement *
              UI.screenWidth(context),
          height: double.infinity,
          child: ticked
              ? Icon(
                  Icons.done,
                  color: textColor,
                )
              : Text(
                  text,
                  style: defaultText(false).merge(TextStyle(color: textColor)),
                ),
        ),
      );

  static Widget playerTeamsTable(
          {@required BuildContext context,
          @required List<String> playerNames,
          @required List<int> playerTeams,
          @required void changePlayerTeam(int playerNo, int newTeam)}) =>
      Container(
        decoration: BoxDecoration(
          border: Border.all(
              width: globals.buttonBorderSize, color: globals.buttonBorder),
          borderRadius: BorderRadius.circular(globals.buttonClipSize),
        ),
        width: UI.getHalfWidth(context) * UI.screenWidth(context),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          itemCount: globals.maxLANPlayers + 1,
          itemBuilder: (BuildContext context, int y) {
            return Container(
              height: UI.getHalfHeight(context) *
                  globals.tableElement *
                  globals.heightMultiplier *
                  UI.screenHeight(context),
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: globals.maxLANPlayers + 1,
                  itemBuilder: (BuildContext context, int x) {
                    if (x == 0 && y == 0) {
                      return tableCell(context);
                    } else if (x == 0) {
                      return tableCell(
                        context,
                        text: playerNames[y - 1],
                        textColor: globals.teamColors[playerTeams[y - 1] - 1],
                      );
                    } else if (y == 0) {
                      return tableCell(
                        context,
                        text: globals.defaultTeamNames[x - 1],
                        textColor: globals.teamColors[x - 1],
                      );
                    } else {
                      return tableCell(context, onTap: () => changePlayerTeam(y, x),
                          ticked: playerTeams[y - 1] == x,
                          textColor: globals.teamColors[x - 1]);
                    }
                  }),
            );
          },
        ),
      );
}
