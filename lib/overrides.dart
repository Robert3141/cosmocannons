import 'dart:ui';
import 'package:client_server_lan/client_server_lan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cosmocannons/globals.dart' as globals;
import 'package:flutter/rendering.dart';

extension OffsetExtender on Offset {
  /// Take values between 0 and 1 and convert to between 0 and globals.canvasSize
  Offset toRelative() {
    double newX = this.dx * globals.canvasSize.width;
    double newY = (1 - this.dy) * globals.canvasSize.height;
    return Offset(newX, newY);
  }

  /// Take values between 0 and globals.canvasSize and convert to between 0 and 1
  Offset toActual() {
    double newX = this.dx / globals.canvasSize.width;
    double newY = 1 - (this.dy / globals.canvasSize.height);
    return Offset(newX, newY);
  }

  bool checkInRadius(Offset hitbox, double hitboxRadius) {
    Offset item = this;
    return item.dx > hitbox.dx - hitboxRadius &&
        item.dx < hitbox.dx + hitboxRadius &&
        item.dy > hitbox.dy - hitboxRadius &&
        item.dy < hitbox.dy + hitboxRadius;
  }

  void print() {
    debugPrint("${this.dx} ${this.dy}");
  }

  Offset shift() {
    return this.translate(this.dx, this.dy);
  }

  Offset operator *(num other) {
    return this.scale(other.toDouble(), other.toDouble());
  }

  Offset operator /(num other) {
    double fraction = 1 / other;
    return this.scale(fraction, fraction);
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

extension packetExtender on DataPacket {
  /// Gets int no of connected client
  int clientNo(ServerNode server) {
    int clientNo;

    for (int i = 0; i < server.clientsConnected.length; i++) {
      if (server.clientsConnected[i].address == "${this.host}:${this.port}") {
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
    List<String> list = List.empty(growable: true);
    if (this.startsWith("[") && this.endsWith("]")) {
      data = this.substring(1, this.length - 1);
      list = data.split(", ");
    } else {
      throw "parse Error";
    }
    return list;
  }

  List<bool> parseListBool() {
    List<String> stringList = this.parseListString();
    List<bool> booleans = List.empty(growable: true);
    for (int i = 0; i < stringList.length; i++) {
      booleans.add(stringList[i] == "true");
    }
    return booleans;
  }

  List<int> parseListInt() {
    List<String> stringList = this.parseListString();
    List<int> ints = List.empty(growable: true);
    for (int i = 0; i < stringList.length; i++) {
      ints.add(int.parse(stringList[i]));
    }
    return ints;
  }

  Offset parseOffset() {
    String offsetData = this.trim();
    List<String> values = List.empty(growable: true);
    double x;
    double y;
    offsetData = offsetData.substring(7, offsetData.length - 1);
    values = offsetData.split(",");
    x = double.parse(values[0]);
    y = double.parse(values[1]);
    return Offset(x, y);
  }
}

extension ServerExtender on ServerNode {
  void sendToEveryone(String title, dynamic payload, int amountOfPlayers) {
    for (int i = 0;
        i < globals.server.clientsConnected.length && i < amountOfPlayers;
        i++) {
      String address = globals.server.clientsConnected[i].address;
      globals.server.sendData(title, payload, address);
    }
  }
}
