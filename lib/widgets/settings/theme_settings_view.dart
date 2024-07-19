import 'package:collection/collection.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:flutter/material.dart';

class ThemeSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView> {
  late final Map<bool, List<ThemeColor>> options;
  late ThemeColor _themeColor;

  @override
  void initState() {
    super.initState();
    options = ThemeColor.values
        .groupListsBy((themeColor) => themeColor.isBestInDarkMode);
    _themeColor = Preferences.themeColor.value;
  }

  void _onOptionTapped(ThemeColor themeColor) {
    setState(() {
      _themeColor = Preferences.themeColor.value = themeColor;
    });
  }

  Widget themeColorTile(ThemeColor themeColor) => ListTile(
        title: Text(themeColor.displayName),
        leading: Icon(Icons.circle, color: themeColor.color),
        trailing: Radio<ThemeColor>(
          groupValue: _themeColor,
          value: themeColor,
          onChanged: (_) {
            _onOptionTapped(themeColor);
          },
        ),
        onTap: () {
          _onOptionTapped(themeColor);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Theme'),
      body: ListView(
        children: [
          for (final themeColor in options[false]!) themeColorTile(themeColor),
          const HeaderListTile('Best in Dark Mode'),
          for (final themeColor in options[true]!) themeColorTile(themeColor),
        ],
      ),
    );
  }
}
