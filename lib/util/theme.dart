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
  blueGrey('Blue-Grey', Colors.blueGrey),
  yellow('Yellow', Colors.yellow, isBestInDarkMode: true);

  final String displayName;
  final MaterialColor color;
  final bool isBestInDarkMode;

  Color get foregroundColor => isBestInDarkMode ? Colors.black : Colors.white;

  const ThemeColor(this.displayName, this.color,
      {this.isBestInDarkMode = false});
}

ThemeData finaleTheme(ThemeColor themeColor, Brightness brightness) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: themeColor.color,
    brightness: brightness,
    primary: themeColor.color,
    surface: brightness == Brightness.dark ? Colors.black : null,
    onPrimary: themeColor.foregroundColor,
  );

  return ThemeData(
    colorScheme: colorScheme,
    brightness: brightness,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      foregroundColor: themeColor.foregroundColor,
      backgroundColor: themeColor.color,
    ),
    datePickerTheme: DatePickerThemeData(
      todayForegroundColor: WidgetStateProperty.all(themeColor.foregroundColor),
    ),
    tabBarTheme: TabBarTheme(
      indicatorColor: themeColor.color,
      labelColor: themeColor.color,
    ),
  );
}

/// Returns a [ThemeData] whose `tabBarTheme` is appropriate a [TabBar] on an
/// [AppBar].
///
/// The app-wide `tabBarTheme` (defined above) is meant to go on top of the
/// background color, so it uses the theme color as the indicator and label
/// color. In an [AppBar], the theme color is the background color, so we need
/// to use the foreground color as the indicator and label color instead.
ThemeData tabBarThemeDataForAppBar(ThemeColor themeColor) => ThemeData(
      tabBarTheme: TabBarTheme(
        indicatorColor: themeColor.foregroundColor,
        labelColor: themeColor.foregroundColor,
        unselectedLabelColor: themeColor.foregroundColor,
      ),
    );
