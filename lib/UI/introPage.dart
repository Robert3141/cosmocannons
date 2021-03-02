import 'package:cosmocannons/UI/globalUIElements.dart';
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class IntroPage extends StatefulWidget {
  //constructor of the class
  IntroPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  //locals

  //functions
  void backToLauncher() =>
      UI.startNewPage(context, [], newPage: LauncherPage());

  Widget centerWidget(String imageAddress) {
    switch (imageAddress) {
      case 'arrows':
        return Wrap(children: [
          Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.green,
            size: 150,
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.green,
            size: 150,
          )
        ]);
      default:
        return Image.asset(
          imageAddress,
          height: 150,
        );
    }
  }

  //build UI
  @override
  Widget build(BuildContext context) {
    var titles = globals.introTitles;
    var bodies = globals.introBodies;
    var images = globals.introImages;
    var titleTextStyle = TextStyle(
      fontFamily: globals.fontName,
      color: globals.textColor,
      fontWeight: FontWeight.bold,
      fontSize: 30,
    );
    var pages = List<Slide>.generate(
        titles.length,
        (int i) => Slide(
            title: titles[i] ?? '',
            description: bodies[i] ?? '',
            marginTitle: EdgeInsets.zero,
            centerWidget: centerWidget(images[i]),
            styleTitle: titleTextStyle,
            styleDescription: UI.defaultText(),
            backgroundColor: Colors.black));
    ;
    var page = IntroSlider(
      slides: pages,
      onDonePress: backToLauncher,
      onSkipPress: backToLauncher,
      isShowDotIndicator: true,
      colorDot: Colors.white38,
      colorActiveDot: Colors.white,
      styleNameDoneBtn: UI.defaultText(),
      styleNamePrevBtn: UI.defaultText(),
      styleNameSkipBtn: UI.defaultText(),
    );
    return page;
  }
}
