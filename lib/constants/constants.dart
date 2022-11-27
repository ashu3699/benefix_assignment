import 'package:flutter/material.dart';

import '../utils/utils.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;

  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}

enum CalendarState { activeHigh, activeLow, inActive }

class CalendarColors {
  static const Color inActiveState = Color(0xFF7E858E);
  static const Color activeStateHigh = Color(0xFFFF602E);
  static const Color activeStateLow = Color(0xFF3F8CFF);
}

Color getStateColor(Event event) {
  switch (event.state) {
    case CalendarState.activeHigh:
      return CalendarColors.activeStateHigh;
    case CalendarState.activeLow:
      return CalendarColors.activeStateLow;
    case CalendarState.inActive:
      return CalendarColors.inActiveState;
    default:
      return CalendarColors.inActiveState;
  }
}
