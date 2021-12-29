import 'package:flutter/material.dart';

enum ThemeColor {
  red,
  pink,
  purple,
  deepPurple,
  indigo,
  blue,
  lightBlue,
  cyan,
  teal,
  green,
  lightGreen,
  orange,
  brown,
  blueGrey,
}

extension ThemeColorData on ThemeColor {
  String get displayName {
    switch (this) {
      case ThemeColor.red:
        return 'Red';
      case ThemeColor.pink:
        return 'Pink';
      case ThemeColor.purple:
        return 'Purple';
      case ThemeColor.deepPurple:
        return 'Deep Purple';
      case ThemeColor.indigo:
        return 'Indigo';
      case ThemeColor.blue:
        return 'Blue';
      case ThemeColor.lightBlue:
        return 'Light Blue';
      case ThemeColor.cyan:
        return 'Cyan';
      case ThemeColor.teal:
        return 'Teal';
      case ThemeColor.green:
        return 'Green';
      case ThemeColor.lightGreen:
        return 'Light Green';
      case ThemeColor.orange:
        return 'Orange';
      case ThemeColor.brown:
        return 'Brown';
      case ThemeColor.blueGrey:
        return 'Blue-Grey';
    }
  }

  Color get color {
    switch (this) {
      case ThemeColor.red:
        return Colors.red;
      case ThemeColor.pink:
        return Colors.pink;
      case ThemeColor.purple:
        return Colors.purple;
      case ThemeColor.deepPurple:
        return Colors.deepPurple;
      case ThemeColor.indigo:
        return Colors.indigo;
      case ThemeColor.blue:
        return Colors.blue;
      case ThemeColor.lightBlue:
        return Colors.lightBlue;
      case ThemeColor.cyan:
        return Colors.cyan;
      case ThemeColor.teal:
        return Colors.teal;
      case ThemeColor.green:
        return Colors.green;
      case ThemeColor.lightGreen:
        return Colors.lightGreen;
      case ThemeColor.orange:
        return Colors.deepOrange;
      case ThemeColor.brown:
        return Colors.brown;
      case ThemeColor.blueGrey:
        return Colors.blueGrey;
    }
  }
}

class FinaleTheme {
  static ThemeData lightFor(ThemeColor themeColor) {
    final colorScheme = ColorScheme.light(
      primary: themeColor.color,
      secondary: themeColor.color,
      surface: themeColor.color,
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      timePickerTheme:
          TimePickerThemeData(backgroundColor: colorScheme.background),
      cardColor: colorScheme.background,
    );
  }

  static ThemeData darkFor(ThemeColor themeColor) {
    final colorScheme = ColorScheme.dark(
      primary: themeColor.color,
      secondary: themeColor.color,
      surface: themeColor.color,
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      timePickerTheme:
          TimePickerThemeData(backgroundColor: colorScheme.background),
      toggleableActiveColor: colorScheme.primary,
      cardColor: colorScheme.background,
    );
  }
}
