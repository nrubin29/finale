import 'package:flutter/material.dart';

class HeaderListTile extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const HeaderListTile(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title),
      trailing: trailing,
      visualDensity: VisualDensity.compact,
      textColor: theme.brightness == Brightness.light
          ? theme.primaryColor
          : Colors.white,
      tileColor: theme.brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[800],
    );
  }
}
