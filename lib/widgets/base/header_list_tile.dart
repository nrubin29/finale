import 'package:flutter/material.dart';

class HeaderListTile extends StatelessWidget {
  final String title;
  final String? trailing;

  const HeaderListTile({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title),
      trailing: trailing == null ? null : Text(trailing!),
      visualDensity: VisualDensity.compact,
      textColor: theme.brightness == Brightness.light
          ? theme.primaryColor
          : Colors.white,
      tileColor: theme.dividerColor,
    );
  }
}
