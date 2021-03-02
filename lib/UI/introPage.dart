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

  //build UI
  @override
  Widget build(BuildContext context) {
    var titles = globals.introTitles;
    var bodies = globals.introBodies;
    var images = globals.introImages;
    var pages = List<Slide>.generate(
        titles.length,
        (int i) => Slide(
            title: titles[i] ?? '',
            description: bodies[i] ?? '',
            pathImage: images[i],
            styleTitle: UI.defaultText(true),
            styleDescription: UI.defaultText(),
            backgroundColor: Colors.black));
    ;
    var page = IntroSlider(
      slides: pages,
      onDonePress: backToLauncher,
      onSkipPress: backToLauncher,
    );
    return page;
  }
}
