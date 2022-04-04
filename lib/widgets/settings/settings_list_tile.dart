import 'package:finale/util/preference.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Preference<bool, bool> preference;

  const SettingsListTile({
    required this.title,
    this.description,
    required this.icon,
    required this.preference,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
        stream: preference.changes,
        initialData: preference.value,
        builder: (_, snapshot) => CaptionedListTile(
          title: title,
          caption: description,
          icon: icon,
          trailing: Switch(
            value: snapshot.data!,
            onChanged: (value) {
              preference.value = value;
            },
          ),
          onTap: () {
            preference.value = !snapshot.data!;
          },
        ),
      );
}
