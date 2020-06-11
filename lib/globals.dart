library cosmocannons.globals;

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
const String hostName = "Host Name";
const String hostStartServer = "Start Server";
const String readyUp = "Ready Up";
const String readyForPlay = "Ready";
const String client = "Client";
const String host = "Host";
const String notConnected = "Not Connected";

const List<String> defaultTeamNames = ["R", "G", "B", "Y"];

const List<AssetImage> backgrounds = [
  AssetImage("images/1.png"),
  AssetImage("images/2.png"),
  AssetImage("images/3.png"),
  AssetImage("images/4.png"),
  AssetImage("images/5.png"),
  AssetImage("images/6.png"),
];

const double smallWidth = 0.2;
const double smallHeight = 0.2;
const double tableElement = 0.2;
const double paddingSize = 0.03;
const double buttonBorderSize = 4.0;
const double buttonClipSize = 8.0;
const double largeTextSize = 45.0;
const double smallTextSize = 12.0;
const double heightMultiplier = 1.5;
const double halfButton = 0.48;

const int maxLANPlayers = 4;

const Color buttonFill = Colors.black54;
const Color buttonBorder = Colors.white38;
const Color textColor = Colors.white70;

const List<Color> teamColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow
];

/// VARIABLES

List<String> playerNames = [host, client, client, client];

List<int> playerTeams = [1, 2, 3, 4];
