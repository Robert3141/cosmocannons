library cosmocannons.globals;

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// CONSTANTS

const String fontName = "AstroSpace";
const String gameTitle = "Cosmo Cannons";
const String singleplayer = "Single Player";
const String multiplayer = "Multiplayer";
const String settings = "Settings";
const String achievements = "Achievements";
const String back = "Back";
const String help = "Help";
const String localMulti = "On local device";
const String hostMulti = "LAN Host";
const String clientMulti = "LAN Client";
const String hostName = "Pick Host Name";
const String clientName = "Pick Client Name";
const String hostStartServer = "Start Server";
const String hostStopServer = "Stop Server";
const String clientConnectServer = "Connect To Server";
const String clientDisconenctServer = "Disconnect from Server";
const String readyUp = "Ready Up";
const String readyForPlay = "Ready";
const String client = "Client";
const String host = "Host";
const String notConnected = "Not Connected";
const String paused = "Paused";
const String platformNotSupported = "Not supported on this device";
const String amountOfPlayers = "Amount of players";
const String confirm = "Confirm";
const String shootSetup = "Fire!";
const String shootIntensity = "Intensity";
const String shootAngle = "Angle";

const List<String> defaultTeamNames = ["R", "G", "B", "Y"];
const List<String> playerAmounts = ["2", "3", "4"];
const List<String> defaultFireSetup = ["10", "135"];
const List<String> shootOptions = [shootIntensity, shootAngle];

List<AssetImage> backgrounds = [
  AssetImage("assets/images/1.png"),
  AssetImage("assets/images/2.png"),
  AssetImage("assets/images/3.png"),
  AssetImage("assets/images/4.png"),
  AssetImage("assets/images/5.png"),
  AssetImage("assets/images/6.png"),
];

const double smallWidth = 0.2;
const double smallHeight = 0.2;
const double tableElement = 0.18;
const double paddingSize = 0.03;
const double buttonBorderSize = 4.0;
const double buttonClipSize = 8.0;
const double largeTextSize = 45.0;
const double smallTextSize = 12.0;
const double heightMultiplier = 1.5;
const double halfButton = 0.48;
const double terrainBottomToMid = 0.5;
const double terrainMidToTop = 0.5;
const double terrainOpacity = 1.0;
const double defaultZoom = 2.0;
const double scrollAmount = 200.0;
const double iconSize = 50.0;
const double movementAmount = 0.05;
const double tapNearPlayer = 50;
const double mediumWidth = 0.5;
const double mediumHeight = 0.5;

const List<List<double>> terrainMaps = [
  [0.47, 0.50, 0.52, 0.58, 0.67, 0.72, 0.69],
];

const int maxLANPlayers = 4;
const int terrainRowsToRender = 50;
const int terrainColumnsToRender = 50;

const Color buttonFill = Colors.black54;
const Color buttonBorder = Colors.white38;
const Color disabledBorder = Colors.white10;
const Color textColor = Colors.white70;
const Color disabledText = Colors.white12;
const Color optionToggleColor = Colors.green;

final Color buttonReady = Colors.green.shade900;
final Color buttonNotReady = Colors.red.shade900;

const List<Color> teamColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow
];
const List<Color> terrainColors = [
  Color.fromRGBO(33, 33, 33, terrainOpacity),
  Color.fromRGBO(101, 67, 33, terrainOpacity),
  Color.fromRGBO(0, 128, 0, terrainOpacity)
];

/// VARIABLES

bool firstRender = true;

//int selectedPlayer = -1;

List<String> playerNames = [host, client, client, client];

List<int> playerTeams = [0, 1, 2, 3];

List<List<double>> playerPos;

List<List<Offset>> terrainCacheLocation;

List<Color> terrainCacheColour;

AutoSizeGroup standardTextGroup = AutoSizeGroup();
AutoSizeGroup buttonTextGroup = AutoSizeGroup();

ScrollController gameScroller = ScrollController();

FocusNode gameInputs = FocusNode();

enum GameType { singlePlayer, multiLocal, multiHost, multiClient }

extension GameExtension on GameType {
  bool get startingPlayer {
    switch (this) {
      case GameType.singlePlayer:
        return true;
      case GameType.multiHost:
        return true;
      case GameType.multiLocal:
        return true;
      case GameType.multiClient:
        return false;
      default:
        return null;
    }
  }

  int get playerNumber {
    switch (this) {
      case GameType.singlePlayer:
        return 0;
      case GameType.multiHost:
        return 0;
      case GameType.multiClient:
        return 1;
      case GameType.multiLocal:
        return 0;
      default:
        return null;
    }
  }
}
