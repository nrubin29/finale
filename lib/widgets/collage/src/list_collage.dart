import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/scaled_box.dart';
import 'package:finale/widgets/collage/src/collage_branding.dart';
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
  Widget build(BuildContext context) => ScaledBox(
        targetWidth: 400,
        builder: (context, scale) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
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
            spacing: 8 * scale,
            children: [
              if (includeTitle)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: 12 * scale,
                  children: [
                    Text(
                      'Top ${entityType.displayName}s',
                      style: TextStyle(
                        color: themeColor.foregroundColor,
                        fontSize: 28 * scale,
                      ),
                    ),
                    Text(
                      period.display,
                      style: TextStyle(
                        color: themeColor.foregroundColor,
                        fontSize: 16 * scale,
                      ),
                    ),
                  ],
                ),
              for (final item in items)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16 * scale),
                  child: Row(
                    spacing: 20 * scale,
                    children: [
                      Flexible(
                        flex: 1,
                        child: EntityImage(
                          entity: item,
                          quality: ImageQuality.high,
                          width: 128 * scale,
                          shouldAnimate: false,
                          onLoaded: onImageLoaded,
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayTitle,
                              style: TextStyle(
                                color: themeColor.foregroundColor,
                                fontSize: 20 * scale,
                              ),
                            ),
                            if (item.displaySubtitle != null) ...[
                              Text(
                                item.displaySubtitle!,
                                style: TextStyle(
                                  color: themeColor.foregroundColor,
                                  fontSize: 16 * scale,
                                ),
                              ),
                            ],
                            if (item.displayTrailing != null) ...[
                              SizedBox(height: 2 * scale),
                              Text(
                                item.displayTrailing!,
                                style: TextStyle(
                                  color: themeColor.foregroundColor,
                                  fontSize: 12 * scale,
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
                CollageBranding(
                  themeColor: themeColor,
                  scale: scale,
                ),
            ],
          ),
        ),
      );
}
