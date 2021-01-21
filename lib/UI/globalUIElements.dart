import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cosmocannons/UI/GamePage/mainGame.dart';
import 'package:flutter/cupertino.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences_moretypes/shared_preferences_moretypes.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

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
          int backgroundNo = 1,
          bool padding = true}) =>
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
            padding: padding
                ? EdgeInsets.all(getPaddingSize(context))
                : EdgeInsets.zero,
            child: Wrap(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              ),
            ]),
          ),
        ),
      );

// This is a widget which provide the top part of the UI consisting of the page title plus the optional help and back buttons
  static Container topTitle(
          {@required String titleText,
          @required BuildContext context,
          String helpText = "",
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
                globals.popup ? "" : titleText,
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
                    text: globals.help,
                    onTap: () => UI.textDisplayPopup(
                        context, helpText), //TODO add help text for all pages
                    context: context,
                    enabled: helpText != ""),
          ],
        ),
      );

  // This is the widget for the standard button used within the app.
  static GestureDetector largeButton(
      {@required Function onTap,
      @required BuildContext context,
      String text = "",
      double width,
      double height,
      Color buttonFill = globals.buttonFill,
      bool enabled = true,
      bool textField = false,
      bool numericTextField = false,
      bool numericData = false,
      IconData icon,
      TextEditingController controller}) {
    return GestureDetector(
      onTap: enabled
          ? textField
              ? () {}
              : onTap
          : () {},
      child: Container(
        width: screenWidth(context) * (width ?? getHalfWidth(context)),
        height: screenHeight(context) * (height ?? getHalfHeight(context)),
        decoration: BoxDecoration(
            border: Border.all(
                width: globals.buttonBorderSize,
                color: enabled ? globals.buttonBorder : globals.disabledBorder),
            borderRadius: BorderRadius.circular(globals.buttonClipSize),
            color: enabled ? buttonFill : globals.buttonFill),
        alignment: Alignment.center,
        child: textField
            ? TextField(
                keyboardType: numericData
                    ? TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.text,
                inputFormatters: [
                  numericData
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.singleLineFormatter,
                ],
                onChanged: (String newText) {
                  newText ??= "";
                  onTap(newText);
                },
                controller: controller ?? TextEditingController(text: text),
                maxLength: 10,
                textAlign: TextAlign.center,
                style: defaultText(false, enabled),
              )
            : (icon != null)
                ? IconButton(
                    icon: Icon(icon),
                    onPressed: onTap,
                    color: globals.textColor,
                    iconSize: globals.iconSize,
                  )
                : AutoSizeText(
                    text,
                    group: globals.buttonTextGroup,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: defaultText(false, enabled),
                  ),
      ),
    );
  }

  // Quater button
  static GestureDetector halfButton({
    @required Function onTap,
    @required BuildContext context,
    String text = "",
    bool enabled = true,
    bool quaterButton = false,
    IconData icon,
    Color buttonFill = globals.buttonFill,
  }) =>
      largeButton(
        text: text,
        onTap: onTap,
        context: context,
        width: quaterButton
            ? UI.getHalfWidth(context) * globals.halfButton
            : UI.getHalfWidth(context),
        height: UI.getHalfHeight(context) *
            globals.halfButton *
            globals.heightMultiplier,
        enabled: enabled,
        buttonFill: buttonFill,
        icon: icon,
      );

  // This is a unique widget for the small buttons used for the home page, back button and the about page button
  static GestureDetector smallButton(
          {@required String text,
          @required Function onTap,
          @required BuildContext context,
          textField = false,
          enabled = true,
          TextEditingController controller}) =>
      largeButton(
          text: text,
          onTap: onTap,
          context: context,
          width: globals.smallWidth,
          height: globals.smallHeight,
          textField: textField,
          controller: controller,
          enabled: enabled);

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
          @required List<bool> playerEnabled,
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
                        text: playerEnabled[y - 1] ? playerNames[y - 1] : "",
                        textColor: globals.teamColors[playerTeams[y - 1]],
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
                          onTap: playerEnabled[y - 1]
                              ? () {
                                  changePlayerTeam(y, x - 1);
                                }
                              : () {},
                          ticked: playerEnabled[y - 1] &&
                              playerTeams[y - 1] == x - 1,
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

  //launching game
  static void startNewPage(BuildContext context, List<int> playerTeams,
      {StatefulWidget newPage,
      Alignment alignment = Alignment.bottomCenter,
      globals.GameType type = globals.GameType.multiLocal,
      bool resumed = false,
      chosenMap = globals.defaultMap}) {
    if (newPage == null)
      newPage = MainGamePage(
        playerTeams: playerTeams,
        type: type,
        resumed: resumed,
        mapNo: chosenMap,
      );
    Navigator.of(context).pushAndRemoveUntil(
        PageTransition(
            type: PageTransitionType.scale,
            child: newPage,
            alignment: alignment),
        (route) => false);
  }

  static Container optionToggle({
    @required Function(int) onTap,
    @required BuildContext context,
    List<dynamic> items,
    List<Color> fillColors,
    double width,
    double height,
    double heightMultiplier = 1,
    Color selectedItemFill = globals.optionToggleColor,
    Color defaultFill = globals.buttonFill,
    bool enabled = true,
    int selectedInt = 0,
    bool selectedBool = false,
    String title,
  }) =>
      Container(
          height: height ??
              (screenHeight(context) *
                  getHalfHeight(context) *
                  globals.heightMultiplier *
                  globals.halfButton *
                  heightMultiplier),
          child: Column(children: [
            title == null ? Container() : textWidget(title),
            Container(
                height: height ??
                    (heightMultiplier *
                            screenHeight(context) *
                            getHalfHeight(context) *
                            globals.heightMultiplier *
                            globals.halfButton *
                            (title == null ? 1 : 0.95) -
                        (globals.buttonBorderSize * 2)),
                width: screenWidth(context) * (width ?? getHalfWidth(context)),
                decoration: BoxDecoration(
                    border: Border.all(
                      width: globals.buttonBorderSize,
                      color: enabled
                          ? globals.buttonBorder
                          : globals.disabledBorder,
                    ),
                    borderRadius:
                        BorderRadius.circular(globals.buttonClipSize)),
                child: ListView.builder(
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int selectedItem) {
                      return GestureDetector(
                        onTapDown: (deats) => onTap(selectedItem),
                        child: Container(
                          width: screenWidth(context) *
                              (width ?? (getHalfWidth(context))) /
                              items.length,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: enabled
                                  ? items.length == 2
                                      //choose boolean input
                                      ? selectedBool == (selectedItem == 1)
                                          ? fillColors != null
                                              ? fillColors[selectedItem]
                                              : selectedItemFill
                                          : defaultFill
                                      //choose integer input
                                      : selectedItem == selectedInt
                                          ? fillColors != null
                                              ? fillColors[selectedItem]
                                              : selectedItemFill
                                          : defaultFill
                                  : globals.buttonFill),
                          child: items[selectedItem].runtimeType == String
                              ? textWidget(items[selectedItem])
                              : items[selectedItem].runtimeType == IconData
                                  ? IconButton(
                                      icon: Icon(
                                        items[selectedItem],
                                        color: globals.textColor,
                                      ),
                                      onPressed: null,
                                      iconSize: globals.iconSize,
                                    )
                                  : Container(),
                        ),
                      );
                    }))
          ]));

  static Future textDisplayPopup(BuildContext context, String text,
      {String title = "", bool dismissable = true, TextStyle style}) {
    //local vars
    List<Widget> children = [];

    //popup
    globals.popup = true;

    //title
    children.add(Container(
        padding: EdgeInsets.symmetric(vertical: UI.getPaddingSize(context)),
        child: Text(
          title,
          style: UI.defaultText(true),
          textAlign: TextAlign.center,
        )));
    children.add(Container(
      height: UI.getPaddingSize(context),
    ));
    //text
    children.add(Container(
        padding: EdgeInsets.symmetric(vertical: UI.getPaddingSize(context)),
        child: Text(
          text,
          style: style ?? UI.defaultText(false),
          textAlign: TextAlign.center,
        )));
    return showDialog(
      barrierColor: globals.disabledBorder,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) =>
          UI.gamePopup(children, context, (bool b) {
        return;
      }, dismissable, []),
    );
  }

  static Future dataInputPopup(
      BuildContext context, List<Function(String)> dataChange,
      {List<String> dataTitle = const [""],
      List<bool> numericData = const [false],
      List<String> data = const [""],
      String title = "",
      bool notInput = false,
      bool barrierDismissable = true,
      Function(bool confirm) onFinish}) {
    List<Widget> children = [];

    //popup
    globals.popup = true;

    //make sure other arrays is same size and dataChange
    while (dataTitle.length < dataChange.length) dataTitle.add("");
    while (data.length < dataChange.length) data.add("");
    while (numericData.length < dataChange.length) numericData.add(false);
    Function tempFinish = onFinish ?? (bool confirm) {};
    onFinish = (bool confirm) {
      globals.popup = false;
      tempFinish(confirm);
    };

    //title
    children.add(Container(
        padding: EdgeInsets.symmetric(vertical: UI.getPaddingSize(context)),
        child: Text(
          title,
          style: UI.defaultText(true),
          textAlign: TextAlign.center,
        )));
    children.add(Container(
      height: UI.getPaddingSize(context),
    ));
    //buttons
    for (int i = 0; i < dataChange.length; i++) {
      children.add(Column(
        children: [
          UI.textWidget(dataTitle[i]),
          notInput
              ? UI.textWidget(data[i])
              : UI.largeButton(
                  numericData: numericData[i],
                  height: globals.smallHeight,
                  text: data[i],
                  onTap: dataChange[i],
                  context: context,
                  textField: !notInput,
                ),
          Container(
            height: UI.getPaddingSize(context),
          )
        ],
      ));
    }
    return showDialog(
      barrierColor: globals.disabledBorder,
      barrierDismissible: barrierDismissable,
      context: context,
      builder: (BuildContext context) => UI.gamePopup(
          children, context, onFinish, barrierDismissable, dataChange),
    );
  }

  static Widget textWidget(String text,
          {TextAlign spacing = TextAlign.center, double fontSize = 1}) =>
      AutoSizeText(
        text,
        textAlign: spacing,
        style: defaultText(),
        maxFontSize: globals.smallTextSize,
        minFontSize: 6,
        maxLines: 1,
        textScaleFactor: fontSize,
        group: globals.standardTextGroup,
      );

  static Dialog gamePopup(
      List<Widget> children,
      BuildContext context,
      Function onFinish(bool confirm),
      bool barrierDismissable,
      List<Function(String)> dataChange,
      {bool textPopup = false}) {
    //on enter:
    FocusNode popupKeyboard = FocusNode();
    Timer popupStart = Timer(Duration(milliseconds: 500), () {});

    //add confirm button
    if (children.length == dataChange.length + 2 || textPopup)
      children.add(Column(children: [
        UI.largeButton(
            height: globals.smallHeight,
            text: globals.confirm,
            onTap: () {
              Navigator.of(context).pop();
              onFinish(true);
            },
            context: context)
      ]));
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Color(0x1A1A1A).withOpacity(1),
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: popupKeyboard,
          onKey: (RawKeyEvent key) {
            if (key.logicalKey == LogicalKeyboardKey.enter &&
                !popupStart.isActive) {
              Navigator.of(context).pop();
              onFinish(true);
            }
            if (key.logicalKey == LogicalKeyboardKey.escape) {
              globals.popup = false;
              Navigator.of(context).pop();
              onFinish(false);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: globals.buttonBorderSize,
                color: globals.buttonBorder,
              ),
              borderRadius: BorderRadius.circular(globals.buttonClipSize),
            ),
            width: screenWidth(context) * getHalfWidth(context),
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: children,
            ),
          ),
        ));
  }

  static Future<bool> dataStore(String key, dynamic value) async {
    return await ExtendedPrefs(debug: false).dataStore(key, value);
  }

  static Future<dynamic> dataLoad(String key, String type) async =>
      await ExtendedPrefs(debug: false).dataLoad(key, type);

  static int _position(List<int> list, int value) {
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == value) {
          return i;
        }
      }
      return 0;
    } else
      return 0;
  }

  static Row settingsEntry(
          String key, Function(int) onTap, BuildContext context,
          {List<IconData> icons,
          bool boolVar,
          List<String> texts,
          List<int> ints,
          int intVar}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UI.textWidget(key),
          UI.optionToggle(
              items: icons == null ? texts : icons,
              onTap: onTap,
              height: globals.iconSize * 2,
              context: context,
              selectedBool: boolVar,
              selectedInt: _position(ints, intVar))
        ],
      );

  static bool _supportedMusicPlatform = kIsWeb || Platform.isAndroid;

  static Future playMusic() async {
    /*if (_supportedMusicPlatform) {
      globals.playMusic = await UI.dataLoad(globals.keyMusic, "bool") ?? true;
      if (globals.playMusic && !globals.musicPlayer.isPlaying.value) {
        globals.musicTrack = await UI.dataLoad(globals.keyMusicIndex, "int") ??
            Random().nextInt(globals.songs.length - 1);
        globals.musicSeek = await UI.dataLoad(globals.keyMusicSeek, "int") ?? 0;
        await globals.musicPlayer.open(
            Playlist(audios: globals.songs, startIndex: globals.musicTrack),
            autoStart: false,
            loopMode: LoopMode.playlist,
            showNotification: false,
            playInBackground: PlayInBackground.disabledPause,
            respectSilentMode: true,
            seek: Duration(milliseconds: globals.musicSeek));
        await globals.musicPlayer.play();
      } else
        stopMusic();
    }*/
  }

  static Future stopMusic() async {
    /*if (_supportedMusicPlatform) {
      if (globals.musicPlayer.isPlaying.value) {
        globals.musicSeek =
            globals.musicPlayer.currentPosition.value.inMilliseconds;
        globals.musicTrack = globals.musicPlayer.current.value.index;
        await UI.dataStore(globals.keyMusicSeek, globals.musicSeek);
        await UI.dataStore(globals.keyMusicIndex, globals.musicTrack);
      }
      globals.musicPlayer.stop();
      globals.musicPlayer = AssetsAudioPlayer();
    }*/
  }
}
