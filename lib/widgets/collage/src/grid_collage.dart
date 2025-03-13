import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/widgets/base/app_icon.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';

class GridCollage extends StatelessWidget {
  final int gridSize;
  final bool includeTitle;
  final bool includeText;
  final bool includeBranding;
  final Period period;
  final EntityType entityType;
  final List<Entity> items;
  final VoidCallback onImageLoaded;

  const GridCollage(
    this.gridSize,
    this.includeTitle,
    this.includeText,
    this.includeBranding,
    this.period,
    this.entityType,
    this.items,
    this.onImageLoaded,
  );

  @override
  Widget build(BuildContext context) {
    // On tall screens, the size of the grid tile will be constrained by the
    // width of the screen. On wide screens, the size of the grid will be
    // constrained by the height of the screen. We want to calculate both sizes
    // and take the smaller of the two to ensure that we don't overflow
    // regardless of the screen dimensions.
    final size = MediaQuery.of(context).size;
    final widthGridTileSize = size.width / gridSize;
    final heightGridTileSize =
        (size.height - (includeBranding ? 26 : 0) - (includeTitle ? 50 : 0)) /
        gridSize;
    final gridTileSize = min(widthGridTileSize, heightGridTileSize);

    return Container(
      color: Colors.white,
      width: gridTileSize * gridSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (includeTitle)
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Top ${entityType.displayName}s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 6,
                    ),
                  ),
                  SizedBox(width: gridTileSize / 12),
                  Text(
                    period.display,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 8,
                    ),
                  ),
                ],
              ),
            ),
          Flexible(
            child: EntityDisplay(
              items: items,
              displayType: DisplayType.grid,
              scrollable: false,
              showGridTileGradient: includeText,
              gridTileSize: gridTileSize,
              fontSize: includeText ? gridTileSize / 15 : 0,
              gridTileTextPadding: gridTileSize / 15,
              shouldAnimateImages: false,
              onImageLoaded: onImageLoaded,
            ),
          ),
          if (includeBranding)
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  AppIcon(size: gridTileSize / 8),
                  SizedBox(width: gridTileSize / 24),
                  Text(
                    'Created with Finale for Last.fm',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'https://finale.app',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
