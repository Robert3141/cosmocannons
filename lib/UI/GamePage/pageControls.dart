import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:flutter/gestures.dart';
import 'package:cosmocannons/UI/GamePage/gamePaint.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function updateUI;
  final double zoom;
  CustomGestureRecognizer(this.updateUI, this.zoom);

  @override
  String get debugDescription => 'customGestureRecognizer';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _onPanCancel();
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    //check in position
    if (event.localPosition.checkInRadius(
            globals.players[globals.currentPlayer].rPos,
            globals.playerRadius) &&
        !globals.popup) {
      //in player position
      _onPanStart(event.localPosition);
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _onPanUpdate(event.localPosition);
    }
    if (event is PointerUpEvent) {
      _onPanEnd(event.localPosition);
    }
    if (event is PointerCancelEvent) {
      _onPanCancel();
    }
  }

  void _onPanStart(Offset pos) {
    globals.dragGhost = true;
  }

  void _onPanUpdate(Offset pos) {
    //define positions
    Offset playerRelative = globals.players[globals.currentPlayer].rPos;
    Offset arrowRelative = playerRelative.scale(2, 2) - pos;

    //set arrowPos
    globals.arrowTop = arrowRelative.toActual();
    updateUI();
  }

  void _onPanCancel() {
    globals.dragGhost = false;
  }

  void _onPanEnd(Offset pos) {
    globals.dragGhost = false;
    globals.popup = true;

    //shoot
    Offset playerPos = globals.players[globals.currentPlayer].aPos;
    Offset arrow = Offset(-(globals.arrowTop.dx - playerPos.dx),
        globals.arrowTop.dy - playerPos.dy);
    double angle = arrow.direction;
    double intensity = arrow.distance * globals.shootSF; // TODO: continue
    globals.projectiles.add(Projectile.radians(
        intensity, angle, globals.currentPlayer, this.updateUI));
  }
}

/*GestureDetector(
                    //onDoubleTap: () => tapDetails == null ? () {} : doubleTap(),
                    onTapDown: (details) {
                      tapDetails = details;
                    },
                    onDoubleTapDown: (details) {
                      tapDetails = details;
                    },
                    //drag based shooting
                    onPanStart: (details) {
                      Offset tapRelative = details.localPosition;
                      if (tapRelative.checkInRadius(
                              globals.players[globals.currentPlayer].rPos,
                              globals.playerRadius) &&
                          !globals.popup) {
                        globals.dragGhost = true;
                      } else {}
                    },
                    onPanUpdate: (details) {
                      //define positions
                      if (globals.dragGhost) {
                        Offset tapRelative = details.localPosition;
                        Offset playerRelative =
                            globals.players[globals.currentPlayer].rPos;
                        Offset arrowRelative =
                            playerRelative - tapRelative + playerRelative;

                        //set arrowPos
                        setState(() {
                          globals.arrowTop = arrowRelative.toActual();
                        });
                      }
                    },
                    onPanCancel: () {
                      if (globals.dragGhost) {
                        setState(() {
                          globals.dragGhost = false;
                        });
                      }
                    },
                    onPanEnd: (details) async {
                      if (globals.dragGhost) {
                        globals.dragGhost = false;
                        globals.popup = true;

                        //shoot
                        Offset playerPos =
                            globals.players[globals.currentPlayer].aPos;
                        Offset arrow = Offset(
                            -(globals.arrowTop.dx - playerPos.dx),
                            globals.arrowTop.dy - playerPos.dy);
                        double angle = arrow.direction;
                        double intensity =
                            arrow.distance * globals.shootSF; // TODO: continue
                        globals.projectiles.add(Projectile.radians(
                            intensity, angle, globals.currentPlayer, updateUI));
                      }
                    },*/
