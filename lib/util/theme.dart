import 'package:flutter/material.dart';

class FinaleTheme {
  static final light = ThemeData.from(colorScheme: _lightColorScheme).copyWith(
      timePickerTheme:
          TimePickerThemeData(backgroundColor: _lightColorScheme.background));

  static final dark = ThemeData.from(colorScheme: _darkColorScheme).copyWith(
    timePickerTheme:
        TimePickerThemeData(backgroundColor: _darkColorScheme.background),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateColor.resolveWith((_) => Colors.red),
      trackColor: MaterialStateColor.resolveWith((_) => Colors.red.shade200),
    ),
  );

  static const _lightColorScheme = ColorScheme.light(
      primary: Colors.red, secondary: Colors.red, surface: Colors.red);

  static const _darkColorScheme = ColorScheme.dark(
      primary: Colors.red, secondary: Colors.red, surface: Colors.red);
}
