import 'package:finale/services/lastfm/common.dart';
import 'package:flutter/material.dart';

class TagChips extends StatelessWidget {
  final LTopTags topTags;

  const TagChips({required this.topTags});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 10),
            ...topTags.tags.map((tag) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Chip(label: Text(tag.name)))),
            const SizedBox(width: 10)
          ],
        ));
  }
}
