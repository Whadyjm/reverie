import 'dart:ui';

import 'package:flutter/material.dart';

class AppTextStyle {
  static TextStyle titleStyle(Color textColor) => TextStyle(
    fontFamily: 'instrumental',
    color: textColor,
    fontSize: 40,
    fontWeight: FontWeight.w800,
  );

  static TextStyle subtitleStyle(Color textColor) => TextStyle(
    fontFamily: 'instrumental',
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static TextStyle smallTextStyle(Color textColor) => TextStyle(
    fontFamily: 'instrumental',
    color: textColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle verySmallTextStyle(Color textColor) => TextStyle(
    fontFamily: 'instrumental',
    color: textColor,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}

class RobotoTextStyle {
  static TextStyle titleStyle(Color textColor) => TextStyle(
    fontFamily: 'roboto',
    color: textColor,
    fontSize: 25,
    fontWeight: FontWeight.w800,
  );

  static TextStyle subtitleStyle(Color textColor) => TextStyle(
    fontFamily: 'roboto',
    color: textColor,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static TextStyle smallTextStyle(Color textColor) => TextStyle(
    fontFamily: 'roboto',
    color: textColor,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle small2TextStyle(Color textColor) => TextStyle(
    fontFamily: 'roboto',
    color: textColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle verySmallTextStyle(Color textColor) => TextStyle(
    fontFamily: 'roboto',
    color: textColor,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}
