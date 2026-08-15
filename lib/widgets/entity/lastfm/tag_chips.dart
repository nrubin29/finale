import 'package:finale/services/lastfm/common.dart';
import 'package:material_ui/material_ui.dart';

class TagChips extends StatelessWidget {
  final LTopTags topTags;

  const TagChips({required this.topTags});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: .horizontal,
    padding: const .symmetric(horizontal: 16),
    child: Row(
      children: [
        for (final tag in topTags.tags)
          Padding(
            padding: const .symmetric(horizontal: 2),
            child: Chip(label: Text(tag.name)),
          ),
      ],
    ),
  );
}
