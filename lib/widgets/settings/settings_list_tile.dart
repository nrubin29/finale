import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsListTile({
    required this.title,
    this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CaptionedListTile(
        title: title,
        caption: description,
        icon: icon,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      );
}
