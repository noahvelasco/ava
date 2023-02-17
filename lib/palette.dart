
//palette.dart
import 'package:flutter/material.dart';
class Palette {
  static const MaterialColor maincolors = MaterialColor(
    0xffE9A495, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffe8dbce),// lightish nude
      100: Color(0xff424d55),//grey blue

      /*
      Below are unused colors
       */
      200: const Color(0xffa04332),//30%
      300: const Color(0xff89392b),//40%
      400: const Color(0xff733024),//50%
      500: const Color(0xff5c261d),//60%
      600: const Color(0xff451c16),//70%
      700: const Color(0xff2e130e),//80%
      800: const Color(0xff170907),//90%
      900: const Color(0xff000000),//100%
    },
  );
} // you can define define int 500 as the default shade and add your lighter tints above and darker tints below.