//palette.dart
import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor clrs = MaterialColor(
    0xFF424d55, //cement gray
    <int, Color>{
      50: Color(0xFFe8dbce), //Nice Semi Black
      /*
      Below are unused colors - This have to be included or throws an error
       */
      100: Color(0xFF000000), //
      200: Color(0xFF000000), //
      300: Color(0xff000000), //
      400: Color(0xff000000), //
      500: Color(0xff000000), //
      600: Color(0xff000000), //
      700: Color(0xff000000), //
      800: Color(0xff000000), //
      900: Color(0xff000000), //
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.