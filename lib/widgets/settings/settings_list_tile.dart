import 'package:finale/util/preference.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Preference<bool, bool> preference;

  /// Called before a new value is set.
  ///
  /// If this function resolves to `false`, the new value is not set.
  final Future<bool> Function(bool newValue)? beforeUpdate;

  /// Called after a new value is set.
  final void Function(bool newValue)? afterUpdate;

  const SettingsListTile({
    required this.title,
    this.description,
    required this.icon,
    required this.preference,
    this.beforeUpdate,
    this.afterUpdate,
  });

  Future<void> _updateValue(bool newValue) async {
    if (beforeUpdate != null && !await beforeUpdate!(newValue)) return;
    preference.value = newValue;
    afterUpdate?.call(newValue);
  }

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
            onChanged: _updateValue,
          ),
          onTap: () {
            _updateValue(!snapshot.data!);
          },
        ),
      );
}
