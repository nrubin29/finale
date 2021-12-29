import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class ThemeSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView> {
  late ThemeColor _themeColor;

  @override
  void initState() {
    super.initState();
    _themeColor = Preferences().themeColor;
  }

  void _onOptionTapped(ThemeColor themeColor) {
    setState(() {
      _themeColor = Preferences().themeColor = themeColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Theme'),
      body: ListView(
        children: [
          for (final themeColor in ThemeColor.values)
            ListTile(
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
            ),
        ],
      ),
    );
  }
}
