import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

/// A version of [TwoUp] for displaying information about [Entity]s.
class EntityTwoUp extends StatelessWidget {
  final Entity? entity;
  final List<Widget> listItems;

  const EntityTwoUp({required this.entity, required this.listItems});

  @override
  Widget build(BuildContext context) => TwoUp(
        first: entity == null
            ? null
            : EntityImage(
                entity: entity!,
                quality: ImageQuality.high,
              ),
        second: ListView(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          children: [const SizedBox(height: 16), ...listItems],
        ),
      );
}
