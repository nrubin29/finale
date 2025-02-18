import 'package:finale/util/theme.dart';
import 'package:flutter/material.dart';

class CollageBranding extends StatelessWidget {
  final ThemeColor themeColor;
  final double scale;

  const CollageBranding({required this.themeColor, required this.scale});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created with Finale for Last.fm',
                style: TextStyle(
                  color: themeColor.foregroundColor,
                  fontSize: 14 * scale,
                ),
              ),
              Text(
                'https://finale.app',
                style: TextStyle(
                  color: themeColor.foregroundColor,
                  fontSize: 12 * scale,
                ),
              ),
            ],
          ),
          const Spacer(),
          Image.asset(
            'assets/images/music_note.png',
            width: 14 * scale,
            color: themeColor.foregroundColor,
          ),
        ],
      );
}
