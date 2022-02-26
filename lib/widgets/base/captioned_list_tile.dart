import 'package:flutter/material.dart';

class CaptionedListTile extends StatelessWidget {
  final String title;
  final String? caption;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CaptionedListTile({
    required this.title,
    this.caption,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(title),
            leading: Icon(icon),
            trailing: trailing,
            onTap: onTap,
          ),
          if (caption != null)
            SafeArea(
              top: false,
              bottom: false,
              minimum: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Text(
                caption!,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
        ],
      );
}
