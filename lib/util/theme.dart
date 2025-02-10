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

const _offBlackBackgroundColor = Color.fromRGBO(16, 20, 23, 1);

ThemeData finaleTheme(ThemeColor themeColor, Brightness brightness,
    [bool? offBlackBackground]) {
  var colorScheme = ColorScheme.fromSeed(
    seedColor: themeColor.color,
    brightness: brightness,
    primary: themeColor.color,
    surface: brightness == Brightness.dark
        ? offBlackBackground == true
            ? _offBlackBackgroundColor
            : Colors.black
        : null,
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

/// Returns a [ThemeData] with overrides necessary for an [AppBar].
///
/// The app-wide theme assumes that colorful components are placed on top of a
/// white or black background. In an [AopBar], the background is colorful, so we
/// need to use the foreground color as the accent color instead.
ThemeData themeDataForAppBar(BuildContext context, ThemeColor themeColor) {
  final theme = Theme.of(context);
  return theme.copyWith(
    // Color disabled icon buttons correctly.
    colorScheme:
        theme.colorScheme.copyWith(onSurface: themeColor.foregroundColor),
    tabBarTheme: theme.tabBarTheme.copyWith(
      indicatorColor: themeColor.foregroundColor,
      labelColor: themeColor.foregroundColor,
      unselectedLabelColor: themeColor.foregroundColor,
    ),
  );
}

final minimumSizeButtonStyle = SegmentedButton.styleFrom(
  visualDensity: const VisualDensity(
    horizontal: VisualDensity.minimumDensity,
    vertical: VisualDensity.minimumDensity,
  ),
);
