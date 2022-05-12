import 'package:finale/widgets/base/header_list_tile.dart';
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
  Widget build(BuildContext context) => Column(
        children: [
          HeaderListTile(title, trailing: trailing),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final action in actions)
                OutlinedButton(
                  onPressed: action.onPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon),
                      const SizedBox(width: 8),
                      Text(action.name),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
}
