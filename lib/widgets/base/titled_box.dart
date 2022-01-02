import 'package:flutter/material.dart';

class ButtonAction {
  final String name;
  final IconData icon;
  final VoidCallback onPressed;

  const ButtonAction(this.name, this.icon, this.onPressed);
}

class TitledBox extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<ButtonAction> actions;

  const TitledBox({required this.title, this.trailing, required this.actions});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
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
                  child:
                      Text(title, style: Theme.of(context).textTheme.bodyText1),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final action in actions)
                  OutlinedButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.icon),
                        const SizedBox(width: 8),
                        Text(action.name),
                      ],
                    ),
                    onPressed: action.onPressed,
                  ),
              ],
            ),
          ],
        ),
      );
}
