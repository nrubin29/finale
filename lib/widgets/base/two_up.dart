import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

/// Displays [image] and [listItems] side-by-side if there's enough room;
/// otherwise, displays [image] above [listItems].
class TwoUp extends StatelessWidget {
  final Entity? entity;
  final List<Widget> listItems;

  const TwoUp({required this.entity, required this.listItems});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTwoUp =
        mediaQuery.size.width > 600 &&
        mediaQuery.orientation == Orientation.landscape;
    return isTwoUp
        ? Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (entity != null)
              Flexible(
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                  widthFactor: .8,
                  heightFactor: .8,
                  child: EntityImage(
                    entity: entity!,
                    quality: ImageQuality.high,
                  ),
                ),
              ),
            Flexible(
              fit: FlexFit.tight,
              child: FractionallySizedBox(
                widthFactor: entity == null ? .8 : 1,
                child: ListView(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  children: [const SizedBox(height: 16), ...listItems],
                ),
              ),
            ),
          ],
        )
        : ListView(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          children: [
            if (entity != null)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: mediaQuery.size.height / 2,
                ),
                child: EntityImage(entity: entity!, quality: ImageQuality.high),
              ),
            const SizedBox(height: 10),
            ...listItems,
          ],
        );
  }
}
