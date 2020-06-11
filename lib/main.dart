import 'package:cosmocannons/globals.dart' as globals;
import 'package:cosmocannons/UI/launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  if (kIsWeb) {
    runApp(MyApp());
  } else {
    SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
        .then((_) {
      runApp(new MyApp());
    });
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: globals.gameTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LauncherPage(title: globals.gameTitle),
    );
  }
}
