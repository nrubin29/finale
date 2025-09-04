import 'package:finale/util/preference.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsListTile<T> extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Preference<T, Object> preference;

  /// Called before a new value is set.
  ///
  /// If this function resolves to `false`, the new value is not set.
  final Future<bool> Function(T newValue)? beforeUpdate;

  /// Called after a new value is set.
  final void Function(T newValue)? afterUpdate;

  const SettingsListTile({
    required this.title,
    this.description,
    required this.icon,
    required this.preference,
    this.beforeUpdate,
    this.afterUpdate,
  });

  Future<void> _updateValue(T newValue) async {
    if (beforeUpdate != null && !await beforeUpdate!(newValue)) return;
    preference.value = newValue;
    afterUpdate?.call(newValue);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(
    stream: preference.changes,
    initialData: preference.value,
    builder: (_, snapshot) => CaptionedListTile(
      title: title,
      caption: description,
      icon: icon,
      trailing: T == bool
          ? Switch(
              value: snapshot.data! as bool,
              onChanged: (value) => _updateValue(value as T),
            )
          : preference is EnumPreference
          ? DropdownButton(
              value: preference.value,
              items: [
                for (final value in (preference as EnumPreference).enumValues)
                  DropdownMenuItem(
                    value: value,
                    child: Text(value.displayName),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updateValue(value as T);
                }
              },
            )
          : throw StateError('Cannot create settings editor for type $T'),
      onTap: T == bool
          ? () {
              _updateValue(!(snapshot.data! as bool) as T);
            }
          : null,
    ),
  );
}
