import 'package:flutter/material.dart';

class NumberOneBadge extends StatelessWidget {
  const NumberOneBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor,
      ),
      child: Text('#1', style: TextStyle(color: theme.colorScheme.onPrimary)),
    );
  }
}
