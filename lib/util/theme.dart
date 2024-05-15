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

ThemeData finaleTheme(ThemeColor themeColor, Brightness brightness) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: themeColor.color,
    brightness: brightness,
    primary: themeColor.color,
    surface: brightness == Brightness.dark ? Colors.black : null,
  );

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: themeColor.color,
    ),
  );
}
