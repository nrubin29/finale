import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';

class GridCollage extends StatelessWidget {
  final int gridSize;
  final bool includeBranding;
  final bool includeText;
  final List<Entity> items;

  const GridCollage(
      this.gridSize, this.includeBranding, this.includeText, this.items);

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
        (size.height - (includeBranding ? 26 : 0)) / gridSize;
    final gridTileSize = min(widthGridTileSize, heightGridTileSize);

    return Container(
      color: Colors.white,
      width: gridTileSize * gridSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: EntityDisplay(
              items: items,
              displayType: DisplayType.grid,
              scrollable: false,
              showGridTileGradient: includeText,
              gridTileSize: gridTileSize,
              fontSize: includeText ? gridTileSize / 15 : 0,
              gridTileTextPadding: gridTileSize / 15,
            ),
          ),
          if (includeBranding)
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(children: [
                appIcon(size: gridTileSize / 8),
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
              ]),
            ),
        ],
      ),
    );
  }
}
