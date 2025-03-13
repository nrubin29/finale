import 'package:collection/collection.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';

final _options = ThemeColor.values.groupListsBy(
  (themeColor) => themeColor.isBestInDarkMode,
);

class ThemeSettingsView extends StatelessWidget {
  void _onOptionTapped(ThemeColor themeColor) {
    Preferences.themeColor.value = themeColor;
  }

  Widget themeColorTile(BuildContext context, ThemeColor themeColor) =>
      Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: themeColor.color,
          borderRadius: BorderRadius.circular(16),
          border:
              Preferences.themeColor.value == themeColor
                  ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 3,
                  )
                  : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _onOptionTapped(themeColor);
          },
          child: Center(
            child: Text(
              themeColor.displayName,
              style: TextStyle(color: themeColor.foregroundColor),
            ),
          ),
        ),
      );

  Widget themeColorGrid(BuildContext context, bool isBestInDarkMode) =>
      GridView.extent(
        maxCrossAxisExtent: 120,
        padding: const EdgeInsets.all(4),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final themeColor in _options[isBestInDarkMode]!)
            themeColorTile(context, themeColor),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, 'Theme'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SettingsListTile(
                title: 'Off-black background',
                description:
                    'In dark mode, the background will be off-black instead of '
                    'pure black.',
                icon: Icons.dark_mode,
                preference: Preferences.themeBackground,
              ),
              const HeaderListTile('Colors'),
              themeColorGrid(context, false),
              const HeaderListTile('Best in Dark Mode'),
              themeColorGrid(context, true),
            ],
          ),
        ),
      ),
    );
  }
}
