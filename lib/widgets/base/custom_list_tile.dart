import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const CustomListTile({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const .symmetric(horizontal: 16),
      child: Row(
        spacing: 16,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Expanded(child: trailing),
        ],
      ),
    );
  }
}
