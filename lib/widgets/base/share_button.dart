import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String text;

  const ShareButton({required this.text});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(Icons.adaptive.share),
    onPressed: () {
      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero) & box.size;
      SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: position),
      );
    },
  );
}
