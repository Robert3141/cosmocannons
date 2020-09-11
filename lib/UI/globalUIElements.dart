import 'package:flutter/cupertino.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';

class UI {
  // simplified methods to get the screen details
  static Size screenSize(context) => MediaQuery.of(context).size;
  static double screenWidth(context) => screenSize(context).width;
  static double screenHeight(context) => screenSize(context).height;

  // The standard text style used throughou the app
  static TextStyle defaultText([bool titleText = false, bool enabled = true]) =>
      TextStyle(
        fontFamily: globals.fontName,
        color: enabled ? globals.textColor : globals.disabledText,
        fontWeight: FontWeight.bold,
        fontSize: titleText ? globals.largeTextSize : globals.smallTextSize,
      );

  // This returns an appropriate padding size so that the UI scale looks clean
  static double getPaddingSize(BuildContext context) {
    double h = UI.screenHeight(context);
    double w = UI.screenWidth(context);
    return h > w ? w * globals.paddingSize : h * globals.paddingSize;
  }

  // This and getHalfHeight calculate the width of a widget in order to fit two plus padding on one screen
  static double getHalfWidth(BuildContext context) {
    return ((UI.screenWidth(context) - (3 * getPaddingSize(context))) * 0.5) /
        screenWidth(context);
  }

  // This does the same but for height instead.
  static double getHalfHeight(BuildContext context) {
    return (((UI.screenHeight(context) /*- globals.largeTextSize */ -
                (2 * getPaddingSize(context))) *
            0.5) /
        UI.screenHeight(context));
  }

  // This provides a basis for the app UI with the background
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
                fit: BoxFit.cover),
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

// This is a widget which provide the top part of the UI consisting of the page title plus the optional help and back buttons
  static Container topTitle(
          {@required String titleText,
          @required BuildContext context,
          bool root = false}) =>
      Container(
        width: screenWidth(context),
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
            Container(
              width: screenWidth(context) / 2,
              child: AutoSizeText(
                titleText,
                maxFontSize: globals.largeTextSize,
                minFontSize: globals.smallTextSize,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: defaultText(true),
              ),
            ),
            root
                ? Container()
                : smallButton(
                    text: globals.help, onTap: null, context: context),
          ],
        ),
      );

  // This is the widget for the standard button used within the app.
  static GestureDetector largeButton(
          {@required String text,
          @required Function onTap,
          @required BuildContext context,
          double width,
          double height,
          Color buttonFill = globals.buttonFill,
          bool enabled = true}) =>
      GestureDetector(
        onTap: enabled ? onTap : () {},
        child: Container(
          width: screenWidth(context) * (width ?? getHalfWidth(context)),
          height: screenHeight(context) * (height ?? getHalfHeight(context)),
          decoration: BoxDecoration(
              border: Border.all(
                  width: globals.buttonBorderSize,
                  color:
                      enabled ? globals.buttonBorder : globals.disabledBorder),
              borderRadius: BorderRadius.circular(globals.buttonClipSize),
              color: enabled ? buttonFill : globals.buttonFill),
          alignment: Alignment.center,
          child: AutoSizeText(
            text,
            group: globals.buttonTextGroup,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: defaultText(false, enabled),
          ),
        ),
      );

  // This is a unique widget for the small buttons used for the home page, back button and the about page button
  static GestureDetector smallButton(
          {@required String text,
          @required Function onTap,
          @required BuildContext context}) =>
      largeButton(
          text: text,
          onTap: onTap,
          context: context,
          width: globals.smallWidth,
          height: globals.smallHeight);

  // This is a widget to provide a table like UI. This is primarily for the team selection interface.
  static InkWell tableCell(BuildContext context,
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
              : AutoSizeText(
                  text,
                  maxLines: 1,
                  group: globals.standardTextGroup,
                  style: defaultText(false).merge(TextStyle(color: textColor)),
                ),
        ),
      );

  // This is the widget for the team selection table. It is adaptive based on the size of the arrays
  static Container playerTeamsTable(
          {@required BuildContext context,
          List<String> playerNames,
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
          itemCount: playerNames.length + 1,
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
                  itemCount: playerTeams.length + 1,
                  itemBuilder: (BuildContext context, int x) {
                    if (x == 0 && y == 0) {
                      // Top Left Cell
                      return tableCell(context);
                    } else if (x == 0) {
                      // Left Column Cells
                      return tableCell(
                        context,
                        text: playerNames[y - 1],
                        textColor: globals.teamColors[playerTeams[y - 1] - 1],
                      );
                    } else if (y == 0) {
                      // Top Row Cells
                      return tableCell(
                        context,
                        text: globals.defaultTeamNames[x - 1],
                        textColor: globals.teamColors[x - 1],
                      );
                    } else {
                      // Other Cells
                      return tableCell(context,
                          onTap: () => changePlayerTeam(y, x),
                          ticked: playerTeams[y - 1] == x,
                          textColor: globals.teamColors[x - 1]);
                    }
                  }),
            );
          },
        ),
      );

  //support animations for page transition
  static void gotoNewPage(BuildContext context, StatefulWidget newPage,
          {Alignment alignment = Alignment.topLeft}) =>
      Navigator.of(context).push(PageTransition(
          type: PageTransitionType.scale,
          child: newPage,
          alignment: alignment));

  static Container optionToggle({
    @required List<String> items,
    @required Function(int) onTap,
    @required BuildContext context,
    double width,
    double height,
    Color selectedItemFill = globals.optionToggleColor,
    Color defaultFill = globals.buttonFill,
    bool enabled = true,
    int selectedInt = 0,
    bool selectedBool = false,
  }) =>
      Container(
        width: screenWidth(context) * (width ?? getHalfWidth(context)),
        height: screenHeight(context) * (height ?? getHalfHeight(context)),
        decoration: BoxDecoration(
            border: Border.all(
              width: globals.buttonBorderSize,
              color: enabled ? globals.buttonBorder : globals.disabledBorder,
            ),
            borderRadius: BorderRadius.circular(globals.buttonClipSize)),
        child: ListView.builder(
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int selectedItem) {
              return GestureDetector(
                onTap: onTap(selectedItem),
                child: Container(
                  width: screenWidth(context) *
                      (width ?? getHalfWidth(context)) /
                      items.length,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: enabled
                          ? items.length == 2
                              //choose boolean input
                              ? selectedBool && selectedItem == 1
                                  ? selectedItemFill
                                  : defaultFill
                              //choose integer input
                              : selectedItem == selectedInt
                                  ? selectedItemFill
                                  : defaultFill
                          : globals.buttonFill),
                  child: textWidget(items[selectedItem]),
                ),
              );
            }),
      );

  static Widget textWidget(String text) => AutoSizeText(
        text,
        style: defaultText(),
        maxFontSize: globals.smallTextSize,
        minFontSize: 6,
        maxLines: 1,
        group: globals.standardTextGroup,
      );
}
