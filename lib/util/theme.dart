import 'package:flutter/material.dart';

class FinaleTheme {
  static final light = ThemeData.from(colorScheme: _lightColorScheme).copyWith(
    timePickerTheme:
        TimePickerThemeData(backgroundColor: _lightColorScheme.background),
    cardColor: _lightColorScheme.background,
  );

  static final dark = ThemeData.from(colorScheme: _darkColorScheme).copyWith(
    timePickerTheme:
        TimePickerThemeData(backgroundColor: _darkColorScheme.background),
    toggleableActiveColor: Colors.red,
    cardColor: _darkColorScheme.background,
  );

  static const _lightColorScheme = ColorScheme.light(
      primary: Colors.red, secondary: Colors.red, surface: Colors.red);

  static const _darkColorScheme = ColorScheme.dark(
      primary: Colors.red, secondary: Colors.red, surface: Colors.red);
}
