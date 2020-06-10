import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UI {
  static Size screenSize(context) => MediaQuery.of(context).size;
  static double screenWidth(context) => screenSize(context).width;
  static double screenHeight(context) => screenSize(context).height;

  static TextStyle defaultText({@required bool titleText}) => TextStyle(
        fontFamily: Strings.fontName,
        color: Strings.textColor,
        fontWeight: FontWeight.bold,
        fontSize: titleText ? Strings.largeTextSize : Strings.smallTextSize,
      );

  static double getPaddingSize({@required BuildContext context}) {
    double h = UI.screenHeight(context);
    double w = UI.screenWidth(context);
    return h > w ? w * Strings.paddingSize : h * Strings.paddingSize;
  }

  static double getHalfWidth(BuildContext context) {
    return ((UI.screenWidth(context) - (3 * getPaddingSize(context: context))) *
            0.5) /
        screenWidth(context);
  }

  static double getHalfHeight(BuildContext context) {
    return (((UI.screenHeight(context) /*- Strings.largeTextSize */ -
                (2 * getPaddingSize(context: context))) *
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
              image: Strings.backgrounds[backgroundNo - 1],
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(getPaddingSize(context: context)),
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
        height: screenHeight(context) * 0.2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            root
                ? Container()
                : smallButton(
                    text: Strings.back,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    context: context,
                  ),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: defaultText(titleText: true),
            ),
            root
                ? Container()
                : smallButton(
                    text: Strings.help, onTap: null, context: context),
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
                  width: Strings.buttonBorderSize, color: Strings.buttonBorder),
              borderRadius: BorderRadius.circular(Strings.buttonClipSize),
              color: Strings.buttonFill),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: defaultText(titleText: false),
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
          width: Strings.smallWidth,
          height: Strings.smallHeight);
}

class Strings {
  static const String fontName = "AstroSpace";
  static const String gameTitle = "Cosmo Cannons";
  static const String singleplayer = "Single Player";
  static const String multiplayer = "Multiplayer";
  static const String settings = "Settings";
  static const String achievements = "Achievements";
  static const String back = "Back";
  static const String help = "Help";
  static const String localMulti = "On local device";
  static const String hostMulti = "LAN Host";
  static const String clientMulti = "LAN Client";
  static const String hostName = "Host Name";
  static const String hostStartServer = "Start Server";
  static const String readyUp = "Ready Up";
  static const String readyForPlay = "Ready";
  static const String client = "Client";
  static const String host = "Host";
  static const String notConnected = "Not Connected";

  static const List<String> teamNames = [
    "R",
    "G",
    "B",
    "Y"
  ];

  static const List<AssetImage> backgrounds = [
    AssetImage("images/1.png"),
    AssetImage("images/2.png"),
    AssetImage("images/3.png"),
    AssetImage("images/4.png"),
    AssetImage("images/5.png"),
    AssetImage("images/6.png"),
  ];

  static const double smallWidth = 0.2;
  static const double smallHeight = 0.2;
  static const double paddingSize = 0.03;
  static const double buttonBorderSize = 4.0;
  static const double buttonClipSize = 8.0;
  static const double largeTextSize = 45.0;
  static const double smallTextSize = 12.0;
  static const double heightMultiplier = 1.5;
  static const double halfButton = 0.48;

  static const int maxLANPlayers = 4;

  static const Color buttonFill = Colors.black54;
  static const Color buttonBorder = Colors.white38;
  static const Color textColor = Colors.white70;

  static const List<Color> teamColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow
  ];
}
