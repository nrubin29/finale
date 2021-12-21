import 'package:flutter/material.dart';

class TitledBox extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Map<String, VoidCallback> actions;

  const TitledBox({required this.title, this.trailing, required this.actions});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(title, style: Theme.of(context).textTheme.bodyText1),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final entry in actions.entries)
                  OutlinedButton(
                    child: Text(entry.key),
                    onPressed: entry.value,
                  ),
              ],
            ),
          ],
        ),
      );
}
