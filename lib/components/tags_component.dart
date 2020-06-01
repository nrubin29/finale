import 'package:flutter/material.dart';
import 'package:simplescrobble/types/lcommon.dart';

class TagsComponent extends StatelessWidget {
  final LTopTags topTags;

  TagsComponent({Key key, @required this.topTags}) : super(key: key);

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
