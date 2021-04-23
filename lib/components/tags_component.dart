import 'package:finale/types/lcommon.dart';
import 'package:flutter/material.dart';

class TagsComponent extends StatelessWidget {
  final LTopTags topTags;

  TagsComponent({@required this.topTags});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 10),
            ...topTags.tags.map((tag) => Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                child: Chip(label: Text(tag.name)))),
            SizedBox(width: 10)
          ],
        ));
  }
}
