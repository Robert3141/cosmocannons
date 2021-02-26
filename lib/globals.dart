library cosmocannons.globals;

import 'dart:ui';
import 'dart:math';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/mapData.dart' as maps;
import 'package:cosmocannons/UI/globalUIElements.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

/// CONSTANTS

const String fontName = 'AstroSpace';
const String gameTitle = 'Cosmo Cannons';
const String singleplayer = 'Single Player';
const String multiplayer = 'Multiplayer';
const String settings = 'Settings';
const String achievements = 'Achievements';
const String back = 'Back';
const String help = 'Help';
const String localMulti = 'On local device';
const String hostMulti = 'LAN Host';
const String clientMulti = 'LAN Client';
const String hostName = 'Pick Host Name';
const String clientName = 'Pick Client Name';
const String hostStartServer = 'Start Server';
const String hostStopServer = 'Stop Server';
const String clientConnectServer = 'Start Client';
const String clientDisconenctServer = 'Disconnect from Server';
const String readyUp = 'Ready Up';
const String readyForPlay = 'Ready';
const String _client = 'Client';
const String _host = 'Host';
const String notConnected = 'Not Connected';
const String paused = 'Paused';
const String platformNotSupported = 'Not supported on this device';
const String amountOfPlayers = 'Amount of players';
const String confirm = 'OK';
const String shootSetup = 'Fire!';
const String shootIntensity = 'Intensity';
const String shootAngle = 'Angle';
const String beginGame = 'Begin';
const String quitWithSave = 'Save and Quit';
const String quitNoSave = 'Exit';
const String allDead = 'No players survived!';
const String welcomeBack = 'Welcome back';
const String saving = 'Saving . . .';
const String loading = 'Loading . . .';
const String resumeGame = 'Resume Game';
const String errorOccurred = 'An error occurred!\nDetails: ';
const String mapChosen = 'Selected Map';
const String warningMapOverwrite =
    'WARNING! About to overwite previous save data';
const String scanClients = 'Scan Players';

const String keyMusic = 'music'; //bool
const String keyVolume = 'sound'; //bool
const String keySavedGame = 'saved'; //bool
const String keyPlayerPosX = 'playerPosX'; //List<double>
const String keyPlayerPosY = 'playerPosY'; //List<double>
const String keyPlayerHealth = 'playerHealth'; //List<double>
const String keyAmountOfPlayers = 'amountOfPlayers'; //int
const String keyCurrentPlayer = 'currentPlayer'; //int
const String keyThisPlayer = 'thisPlayer'; //int
const String keyPlayerTeams = 'playerTeams'; //List<int>
const String keyGameMap = 'gameMap'; //List<double>
const String keyLastFireSetup = 'lastFireSetup'; //List<List<double>>
const String keyGameType = 'gameType'; //GameType
const String keyMovedPlayer = 'movedPlayer'; //bool
const String keyMapNo = 'mapNo'; //int
const String keyRenderHeight = 'graphics'; //int
const String keyMusicIndex = 'musicIndex'; //int
const String keyMusicSeek = 'musicSeek'; //int

const String packetPlayerNames = 'playerNames';
const String packetPlayerNumber = 'playerNumber';
const String packetPlayerEnabled = 'playerEnables';
const String packetPlayerReady = 'playerReady';
const String packetPlayerTeams = 'playerTeams';
const String packetMapNumber = 'mapNumber';
const String packetGameStart = 'gameStart';
const String packetFire = 'fireInfo';
const String packetPlayersTurn = 'playerTurn';
const String packetGameEnd = 'gameEnd';
const String packetPlayerDispose = 'playerDispose';

const String helpMultiplayerHome =
    'On local device is currently the only supported. Multiplayer on the same Wifi Network is coming soon...';
const String helpMultiplayerLocal =
    'Betweeen 2 and 4 players can be selected and the choice of map can be chosen.\nThe Hills map is one large hill in the centre.\nThe Desert map is a flat landscape good for practicing shooting and learning the game.\nThe moon is a funky map with a few different sized hills';
const String helpMultiplayerHost = '';
const String helpMultiplayerClient = '';
const String helpSinglePlayer = '';
const String helpSettings =
    'The toggles on the right allow different settings to be changed.';
const String helpAchievements = '';

const List<String> defaultTeamNames = ['Red', 'Green', 'Blue', 'Yellow'];
const List<String> playerAmounts = ['2', '3', '4'];
const List<String> shootOptions = [shootIntensity, shootAngle];
const List<String> winningPlayerIs = ['The winner is player ', ' from team '];
const List<String> playerNames = [_host, _client, _client, _client];
const List<String> mapNames = ['Hills', 'Desert', 'Moon'];
const List<String> mapQualityString = ['Low', 'Medium', 'High'];

List<AssetImage> backgrounds = [
  AssetImage('assets/images/1.png'),
  AssetImage('assets/images/2.png'),
  AssetImage('assets/images/3.png'),
  AssetImage('assets/images/4.png'),
  AssetImage('assets/images/5.png'),
  AssetImage('assets/images/6.png'),
  //maps
  AssetImage('assets/images/hills.png'),
  AssetImage('assets/images/desert.png'),
  AssetImage('assets/images/moon.png'),
];

/*List<Audio> songs = [
  Audio('assets/music/1.ogg'),
  Audio('assets/music/2.ogg'),
  Audio('assets/music/3.ogg'),
  Audio('assets/music/4.ogg'),
  Audio('assets/music/5.ogg'),
  Audio('assets/music/6.ogg')
];*/

const double smallWidth = 0.2;
const double smallHeight = 0.2;
const double tableElement = 0.18;
const double paddingSize = 0.03;
const double buttonBorderSize = 4.0;
const double buttonClipSize = 8.0;
const double largeTextSize = 45.0;
const double smallTextSize = 12.0;
const double heightMultiplier = 1.5;
const double halfButton = 0.47;
const double thirdButton = 0.31;
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
const double radiansToDegrees = 180 / pi;
const double Ax = 0;
const double Ay = -9.81;
const double xSF = 1 / 10;
const double ySF = 1 / 10;
const double animationSpeed = 3;
const double playerPadding = 0.001;
const double blastRadius = 0.01;
const double blastDamage = 40;
const double defaultPlayerHealth = 100;
const double playerRadius = 27; //mininum 42px
const double playerRadiusX = 0.005;
const double playerRadiusY = 0.03;
const double rangeArrowLength = 20;
const double rangeArrowPadding = 5;
const double shootSF = 62.5;

const List<double> locationInvisible = [-1, -1];
const List<double> defaultFireSetup = [30, 90];

const List<List<double>> terrainMaps = [maps.hills, maps.desert, maps.moon];

const int maxLANPlayers = 4;
const int defualtPlayerAmount = 2;
const int terrainRowsToRender = 50;
const int frameLengthMs = 16;
const int maxFlightLength = 20;
const int checkDoneMs = 100;
const int defaultMap = 0;

const List<int> playerTeams = [0, 1, 2, 3];
const List<int> mapQualitySizes = [5, 25, 50];

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
const List<List<Color>> terrainColors = [
  [
    // hills
    Color.fromRGBO(33, 33, 33, terrainOpacity), //grey
    Color.fromRGBO(101, 67, 33, terrainOpacity), //brown
    Color.fromRGBO(0, 128, 0, terrainOpacity) //green
  ],
  [
    // desert
    Color.fromRGBO(193, 154, 107, terrainOpacity), //camel
    Color.fromRGBO(194, 178, 128, terrainOpacity), //sand
    Color.fromRGBO(236, 226, 198, terrainOpacity) //pearl lusta
  ],
  [
    // moon
    Color.fromRGBO(125, 126, 126, terrainOpacity), //grey
    Color.fromRGBO(161, 132, 132, terrainOpacity), //maroon
    Color.fromRGBO(191, 139, 139, terrainOpacity), //pink
    Color.fromRGBO(204, 142, 127, terrainOpacity), //orange
    Color.fromRGBO(193, 140, 122, terrainOpacity), //brown
  ],
];

/// VARIABLES

bool firstRender = true;
bool popup = false;
bool playMusic = false;
bool playAudio = false;
bool dragGhost = false;
bool firing = false;
bool inGame = false;
bool terrainUpdated = true;

int mapNo;
int terrainColumnsToRender = kIsWeb ? mapQualitySizes[0] : mapQualitySizes[1];
int musicSeek = 0;
//int musicTrack = Random().nextInt(songs.length - 1);
int currentPlayer;
int thisPlayer;

List<double> currentMap;

List<List<Offset>> terrainCacheLocation;

List<Color> terrainCacheColour;

Offset arrowTop = Offset.zero;

Size canvasSize;

GameType type;

ServerNode server;
ClientNode client;

//objects
List<Player> players = List<Player>.empty(growable: true);
List<Projectile> projectiles = List<Projectile>.empty(growable: true);

// Global UI based vars

AutoSizeGroup standardTextGroup = AutoSizeGroup();
AutoSizeGroup buttonTextGroup = AutoSizeGroup();

ScrollController gameScroller = ScrollController();

FocusNode gameInputs = FocusNode();

//AssetsAudioPlayer musicPlayer = AssetsAudioPlayer();

final TextPainter defaultTextPaint = TextPainter(
    text: TextSpan(style: UI.defaultText()),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr);

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

  bool get isLAN {
    return this == GameType.multiHost || this == GameType.multiClient;
  }

  String get string {
    switch (this) {
      case GameType.singlePlayer:
        return 'singlePlayer';
        break;
      case GameType.multiLocal:
        return 'multiLocal';
        break;
      case GameType.multiHost:
        return 'multiHost';
        break;
      case GameType.multiClient:
        return 'multiClient';
        break;
      default:
        return '';
        break;
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
        return false;
        break;
      case GameType.multiClient:
        return false;
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
        return thisPlayer;
      case GameType.multiLocal:
        return 0;
      default:
        return null;
    }
  }
}

GameType gameTypefromString(String s) {
  switch (s) {
    case 'singlePlayer':
      return GameType.singlePlayer;
      break;
    case 'multiLocal':
      return GameType.multiLocal;
      break;
    case 'multiHost':
      return GameType.multiHost;
      break;
    case 'multiClient':
      return GameType.multiClient;
      break;
    default:
      return null;
      break;
  }
}
