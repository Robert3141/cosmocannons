import 'dart:ui';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:flutter/rendering.dart';

extension OffsetExtender on Offset {
  /// Take values between 0 and 1 and convert to between 0 and globals.canvasSize
  Offset toRelative() {
    var newX = dx * globals.canvasSize.width;
    var newY = (1 - dy) * globals.canvasSize.height;
    return Offset(newX, newY);
  }

  /// Take values between 0 and globals.canvasSize and convert to between 0 and 1
  Offset toActual() {
    var newX = dx / globals.canvasSize.width;
    var newY = 1 - (dy / globals.canvasSize.height);
    return Offset(newX, newY);
  }

  bool checkInRadius(Offset hitbox, double hitboxRadius) {
    var item = this;
    return item.dx > hitbox.dx - hitboxRadius &&
        item.dx < hitbox.dx + hitboxRadius &&
        item.dy > hitbox.dy - hitboxRadius &&
        item.dy < hitbox.dy + hitboxRadius;
  }

  void print() {
    debugPrint('$dx $dy');
  }

  Offset shift() {
    return translate(dx, dy);
  }

  Offset operator *(num other) {
    return scale(other.toDouble(), other.toDouble());
  }

  Offset operator /(num other) {
    var fraction = 1 / other;
    return scale(fraction, fraction);
  }
}

extension DoubleExtender on double {
  /// Take values between 0 and 1 and convert to between 0 and globals.canvasSize
  double toRelativeX() {
    return Offset(this, 0).toRelative().dx;
  }

  /// Take values between 0 and 1 and convert to between 0 and globals.canvasSize
  double toRelativeY() {
    return Offset(0, this).toRelative().dy;
  }

  /// Take values between 0 and globals.canvasSize and convert to between 0 and 1
  double toActualX() {
    return Offset(this, 0).toActual().dx;
  }

  /// Take values between 0 and globals.canvasSize and convert to between 0 and 1
  double toActualY() {
    return Offset(0, this).toActual().dy;
  }
}

extension PacketExtender on DataPacket {
  /// Gets int no of connected client
  int clientNo(ServerNode server) {
    int clientNo;

    for (var i = 0; i < server.clientsConnected.length; i++) {
      if (server.clientsConnected[i].address == '$host:$port') {
        clientNo = i;
        i = server.clientsConnected.length;
      }
    }
    return clientNo;
  }
}

extension StringExtender on String {
  /// gets list from List<String>.toString()
  List<String> parseListString() {
    String data;
    var list = List.empty(growable: true);
    if (startsWith('[') && endsWith(']')) {
      data = substring(1, length - 1);
      list = data.split(', ');
    } else {
      throw 'parse Error';
    }
    return list;
  }

  List<bool> parseListBool() {
    var stringList = parseListString();
    var booleans = List<bool>.empty(growable: true);
    for (var i = 0; i < stringList.length; i++) {
      booleans.add(stringList[i] == 'true');
    }
    return booleans;
  }

  List<int> parseListInt() {
    var stringList = parseListString();
    var ints = List<int>.empty(growable: true);
    for (var i = 0; i < stringList.length; i++) {
      ints.add(int.parse(stringList[i]));
    }
    return ints;
  }

  Offset parseOffset() {
    var offsetData = trim();
    var values = List.empty(growable: true);
    double x;
    double y;
    offsetData = offsetData.substring(7, offsetData.length - 1);
    values = offsetData.split(',');
    x = double.parse(values[0]);
    y = double.parse(values[1]);
    return Offset(x, y);
  }
}

extension ServerExtender on ServerNode {
  void sendToEveryone(String title, String payload, int amountOfPlayers) {
    for (var i = 0;
        i < globals.server.clientsConnected.length && i < amountOfPlayers;
        i++) {
      var address = globals.server.clientsConnected[i].address;
      globals.server.sendData(payload, title, address);
    }
  }

  void disposer() {
    //tell them all
    sendToEveryone(globals.packetGameEnd, 'true', globals.players.length);
    //run dispose
    dispose();
  }
}

extension ClientExtender on ClientNode {
  void disposer() {
    sendData(true.toString(), globals.packetGameEnd, serverDetails.address);
  }
}
