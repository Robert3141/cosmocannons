library cosmocannons.globals;

import 'dart:ui';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/UI/globalUIElements.dart';

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
const String confirm = "OK";
const String shootSetup = "Fire!";
const String shootIntensity = "Intensity";
const String shootAngle = "Angle";
const String beginGame = "Begin";
//TODO: add game save
const String quitWithSave = "Quit without saving";
const String allDead = "No players survived!";
const String welcomeBack = "Welcome back";

const String keyMusic = "music";
const String keyVolume = "volume";

const List<String> defaultTeamNames = ["Red", "Green", "Blue", "Yellow"];
const List<String> playerAmounts = ["2", "3", "4"];
const List<String> shootOptions = [shootIntensity, shootAngle];
const List<String> winningPlayerIs = ["The winner is player ", " from team "];
const List<String> playerNames = [host, client, client, client];

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
const double degreesToRadians = pi / 180;
const double Ax = 0;
const double Ay = -9.81;
const double xSF = 1 / 1000;
const double ySF = 1 / 1000;
const double animationSpeed = 3;
const double playerPadding = 0.001;
const double blastRadius = 0.01;
const double blastDamage = -20;
const double defaultPlayerHealth = 100;

const List<double> locationInvisible = [-1, -1];
const List<double> defaultFireSetup = [30, 90];

const List<List<double>> terrainMaps = [
  [0.47, 0.50, 0.52, 0.58, 0.67, 0.72, 0.69],
  /*[
    0.47,
    0.48,
    0.48,
    0.50,
    0.51,
    0.52,
    0.52,
    0.54,
    0.56,
    0.58,
    0.61,
    0.64,
    0.67,
    0.69,
    0.70,
    0.72,
    0.71,
    0.72,
    0.69,
    0.69,
    0.53
  ]*/
];

const int maxLANPlayers = 4;
const int defualtPlayerAmount = 2;
const int terrainRowsToRender = 50;
const int terrainColumnsToRender = 50;
const int frameLengthMs = 16;
const int maxFlightLength = 10;
const int checkDoneMs = 100;

const List<int> playerTeams = [0, 1, 2, 3];

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
  Color.fromRGBO(33, 33, 33, terrainOpacity), //grey
  Color.fromRGBO(101, 67, 33, terrainOpacity), //brown
  Color.fromRGBO(0, 128, 0, terrainOpacity) //green
];

/// VARIABLES

bool firstRender = true;
bool popup = false;
bool playMusic = true;
bool playAudio = true;

List<List<double>> playerPos;

List<double> projectilePos;
List<double> playerHealth;

List<List<Offset>> terrainCacheLocation;

List<Color> terrainCacheColour;

AutoSizeGroup standardTextGroup = AutoSizeGroup();
AutoSizeGroup buttonTextGroup = AutoSizeGroup();

ScrollController gameScroller = ScrollController();

FocusNode gameInputs = FocusNode();

TextPainter defaultTextPaint = TextPainter(
    text: TextSpan(style: UI.defaultText()),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr);

Paint defaultDrawPaint = Paint()
  ..strokeWidth = 0
  ..strokeCap = StrokeCap.butt;

/// DATA TYPES

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

  bool showPlayerUI(int playerNo) {
    switch (this) {
      case GameType.singlePlayer:
        return false;
        break;
      case GameType.multiLocal:
        return true;
        break;
      case GameType.multiHost:
        return playerNo == 0;
        break;
      case GameType.multiClient:
        return playerNo == 1;
        break;
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
