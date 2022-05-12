import 'package:flutter/material.dart';

enum ThemeColor {
  red('Red', Colors.red),
  pink('Pink', Colors.pink),
  purple('Purple', Colors.purple),
  deepPurple('Deep Purple', Colors.deepPurple),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  lightBlue('Light Blue', Colors.lightBlue),
  cyan('Cyan', Colors.cyan),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  lightGreen('Light Green', Colors.lightGreen),
  orange('Orange', Colors.deepOrange),
  brown('Brown', Colors.brown),
  blueGrey('Blue-Grey', Colors.blueGrey);

  final String displayName;
  final MaterialColor color;

  const ThemeColor(this.displayName, this.color);
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
