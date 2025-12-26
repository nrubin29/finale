import 'package:flutter/material.dart';

class CaptionedListTile extends StatelessWidget {
  final Widget title;
  final List<TextSpan> caption;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  CaptionedListTile({
    required String title,
    String? caption,
    required this.icon,
    this.trailing,
    this.onTap,
  }) : title = Text(title),
       caption = [if (caption != null) TextSpan(text: caption)];

  const CaptionedListTile.advanced({
    required this.title,
    required this.caption,
    required this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: .start,
      children: [
        ListTile(title: title, leading: Icon(icon), trailing: trailing),
        if (caption.isNotEmpty)
          SafeArea(
            top: false,
            bottom: false,
            minimum: const .only(left: 16, right: 16, bottom: 12),
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: caption,
              ),
            ),
          ),
      ],
    ),
  );
}
