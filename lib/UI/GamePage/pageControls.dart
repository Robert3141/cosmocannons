import 'dart:math';

import 'package:cosmocannons/UI/GamePage/gameObjects.dart';
import 'package:flutter/gestures.dart';
import 'package:cosmocannons/overrides.dart';
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
  void addPointer(PointerDownEvent event) {
    //check in position
    if (event.localPosition.checkInRadius(
            globals.players[globals.currentPlayer].rPos,
            globals.playerRadius) &&
        !globals.popup &&
        !globals.firing &&
        globals.currentPlayer == globals.thisPlayer) {
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
      _onPanUpdate(event.localDelta);
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
    globals.arrowTop = globals.players[globals.currentPlayer].aPos;
  }

  void _onPanUpdate(Offset delta) {
    //set arrowPos
    globals.arrowTop += Offset(-delta.dx.toActualX(), 1 - delta.dy.toActualY());
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
    double intensity = arrow.distance * globals.shootSF;
    globals.projectiles.add(Projectile.radians(
        intensity, angle, globals.currentPlayer, this.updateUI));

    //share firing of projectile
    Offset velocity = _angleToOffset(intensity, angle);
    if (globals.type == globals.GameType.multiHost)
      globals.server
          .sendToEveryone(globals.packetFire, velocity, globals.players.length);
    if (globals.type == globals.GameType.multiClient)
      globals.client.sendData(globals.packetFire, velocity.toString(),
          globals.client.serverDetails.address);
  }

  Offset _angleToOffset(double intensity, double angleRadians) {
    return Offset(
        intensity * -cos(angleRadians), intensity * sin(angleRadians));
  }
}
