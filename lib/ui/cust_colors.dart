import 'package:flutter/material.dart';

class PColor{
  static const MaterialColor orangeparto = MaterialColor(_orangepartoPrimaryValue, <int, Color>{
    50: Color(0xFFFBEEE8),
    100: Color(0xFFF6D5C7),
    200: Color(0xFFF0B9A1),
    300: Color(0xFFE99C7B),
    400: Color(0xFFE5875F),
    500: Color(_orangepartoPrimaryValue),
    600: Color(0xFFDC6A3D),
    700: Color(0xFFD85F34),
    800: Color(0xFFD3552C),
    900: Color(0xFFCB421E),
  });
  static const int _orangepartoPrimaryValue = 0xFFE07243;

  static const MaterialColor orangepartoAccent = MaterialColor(_orangepartoAccentValue, <int, Color>{
    100: Color(0xFFFFFFFF),
    200: Color(_orangepartoAccentValue),
    400: Color(0xFFFFAE9C),
    700: Color(0xFFFF9982),
  });
  static const int _orangepartoAccentValue = 0xFFFFD7CF;

  static const MaterialColor blueparto = MaterialColor(_bluepartoPrimaryValue, <int, Color>{
    50: Color(0xFFE5E9EC),
    100: Color(0xFFBEC7CE),
    200: Color(0xFF93A2AE),
    300: Color(0xFF677C8E),
    400: Color(0xFF476075),
    500: Color(_bluepartoPrimaryValue),
    600: Color(0xFF223E55),
    700: Color(0xFF1C354B),
    800: Color(0xFF172D41),
    900: Color(0xFF0D1F30),
  });
  static const int _bluepartoPrimaryValue = 0xFF26445D;

  static const MaterialColor bluepartoAccent = MaterialColor(_bluepartoAccentValue, <int, Color>{
    100: Color(0xFFBEC7CE),
    200: Color(_bluepartoAccentValue),
    400: Color(0xFF476075),
    700: Color(0xFF1C354B),
  });
  static const int _bluepartoAccentValue = 0xFF93A2AE;
}