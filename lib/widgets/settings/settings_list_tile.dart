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
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            leading: Icon(icon),
            trailing: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
          if (description != null)
            SafeArea(
              top: false,
              bottom: false,
              minimum: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
        ],
      );
}
