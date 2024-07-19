import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class ListCollage extends StatelessWidget {
  final ThemeColor themeColor;
  final bool includeTitle;
  final bool includeBranding;
  final Period period;
  final EntityType entityType;
  final List<Entity> items;
  final VoidCallback onImageLoaded;

  const ListCollage(this.themeColor, this.includeTitle, this.includeBranding,
      this.period, this.entityType, this.items, this.onImageLoaded);

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.of(context).size.width, 400).toDouble();

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.color.shade500,
            themeColor.color.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (includeTitle) ...[
            Padding(
              padding: EdgeInsets.all(width / 20).copyWith(bottom: 0),
              child: Text(
                'Top ${entityType.name.toTitleCase()}s',
                style: TextStyle(
                  color: themeColor.foregroundColor,
                  fontSize: width / 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.all(width / 20).copyWith(top: 0),
              child: Text(
                period.display,
                style: TextStyle(
                  color: themeColor.foregroundColor,
                  fontSize: width / 24,
                ),
              ),
            ),
          ],
          for (final item in items)
            Padding(
              padding: EdgeInsets.all(width / 20),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: EntityImage(
                      entity: item,
                      quality: ImageQuality.high,
                      shouldAnimate: false,
                      onLoaded: onImageLoaded,
                    ),
                  ),
                  SizedBox(width: width / 20),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayTitle,
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: width / 20,
                          ),
                        ),
                        if (item.displaySubtitle != null) ...[
                          SizedBox(height: width / 75),
                          Text(
                            item.displaySubtitle!,
                            style: TextStyle(
                              color: themeColor.foregroundColor,
                              fontSize: width / 25,
                            ),
                          ),
                        ],
                        if (item.displayTrailing != null) ...[
                          SizedBox(height: width / 75),
                          Text(
                            item.displayTrailing!,
                            style: TextStyle(
                              color: themeColor.foregroundColor,
                              fontSize: width / 30,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (includeBranding)
            Padding(
              padding: EdgeInsets.only(
                left: width / 20,
                right: width / 20,
                bottom: width / 50,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Created with Finale for Last.fm',
                        style: TextStyle(
                          color: themeColor.foregroundColor,
                        ),
                      ),
                      Text(
                        'https://finale.app',
                        style: TextStyle(
                          color: themeColor.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/music_note.png',
                    width: 60,
                    color: themeColor.foregroundColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
