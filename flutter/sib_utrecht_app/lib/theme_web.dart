// Based on https://stackoverflow.com/questions/70230285/is-there-any-way-to-change-the-status-bar-color-via-flutter-in-a-pwa
// answer by https://stackoverflow.com/users/1399597/markus-rubey

import 'package:flutter/material.dart';
import 'dart:js' as js;

extension ColorString on Color {
  String toHexString() {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

void setMetaThemeColor(Color color) {
  print("Doing setMetaThemeColor");
  js.context.callMethod("setMetaThemeColor", [color.toHexString()]);
  print("Finished setMetaThemeColor");
}
