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
const String clientConnectServer = "Connect To Server";
const String readyUp = "Ready Up";
const String readyForPlay = "Ready";
const String client = "Client";
const String host = "Host";
const String notConnected = "Not Connected";

const List<String> defaultTeamNames = ["R", "G", "B", "Y"];

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
const double scrollAmount = 100.0;

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

List<String> playerNames = [host, client, client, client];

List<int> playerTeams = [1, 2, 3, 4];

AutoSizeGroup standardTextGroup = AutoSizeGroup();
AutoSizeGroup buttonTextGroup = AutoSizeGroup();

ScrollController gameScroller = ScrollController();

FocusNode gameInputs = FocusNode();
