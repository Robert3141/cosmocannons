import 'dart:ui';
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
