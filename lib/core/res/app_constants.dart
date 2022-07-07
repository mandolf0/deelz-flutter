import 'package:flutter/material.dart';

class AppConstants {
  static const String projectId = "62c0ba904fcd051b1417";
  // static const String endPoint = "http://192.168.0.64:4003/v1";
  static const String endPoint = "http://apper.ddns.net:4003/v1";
  // static const String endPoint = "http://192.168.0.108:4003/v1";
  static MaterialColor kcPrimary =
      MaterialColor(0xFF366CF6, AppConstants._primaryColor);

  static MaterialColor kcAnotherMaterialColor =
      MaterialColor(0xff09C77B, _anotherColor);
  // Color(0xfff44336);
  //
  static const TextStyle ksTextStyleLight =
      TextStyle(fontSize: 16.0, color: kcPrimaryLigthText);

  static const TextStyle ksTextStyleLightSecondary =
      TextStyle(fontSize: 16.0, color: kcTextSecondary);

  static const Color kcPrimaryLigthText = Color(0xffF0F0F0);

  static const Color kcScaffoldBkg = Color(0xff366CF6);
  static const Color kcPrimaryLight = Color(0xffff7961);
  static const Color kcPrimaryDark = Color(0xffba000d);

  static const Color kcSecondary = Color(0xff09C77B);
  static const Color kcSecondaryLight = Color(0xff8e99f3);
  static const Color kcSecondaryDark = Color(0xff26418f);

  //text colors
  static const Color kcTextPrimary = Color(0xffffffff);
  static const Color kcTextSecondary = Color(0xff000000);

  //paddings

  static const kDefaultPadding = 20.0;

  static MaterialColor buildMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static final Map<int, Color> _primaryColor = {
    50: const Color.fromRGBO(54, 108, 246, .1),
    100: const Color.fromRGBO(54, 108, 246, .2),
    200: const Color.fromRGBO(54, 108, 246, .3),
    300: const Color.fromRGBO(54, 108, 246, .4),
    400: const Color.fromRGBO(54, 108, 246, .5),
    500: const Color.fromRGBO(54, 108, 246, .6),
    600: const Color.fromRGBO(54, 108, 246, .7),
    700: const Color.fromRGBO(54, 108, 246, .8),
    800: const Color.fromRGBO(54, 108, 246, .9),
    900: const Color.fromRGBO(54, 108, 246, 1),
  };
  static final Map<int, Color> _anotherColor = {
    50: const Color.fromRGBO(9, 199, 123, .1),
    100: const Color.fromRGBO(9, 199, 123, .2),
    200: const Color.fromRGBO(9, 199, 123, .3),
    300: const Color.fromRGBO(9, 199, 123, .4),
    400: const Color.fromRGBO(9, 199, 123, .5),
    500: const Color.fromRGBO(9, 199, 123, .6),
    600: const Color.fromRGBO(9, 199, 123, .7),
    700: const Color.fromRGBO(9, 199, 123, .8),
    800: const Color.fromRGBO(9, 199, 123, .9),
    900: const Color.fromRGBO(9, 199, 123, 1),
  };
}
