import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class WikiTile extends StatelessWidget {
  final Entity entity;
  final LWiki wiki;

  const WikiTile({required this.entity, required this.wiki});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          wiki.summary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => _WikiPage(entity: entity, wiki: wiki)),
          );
        },
      );
}

class _WikiPage extends StatelessWidget {
  final Entity entity;
  final LWiki wiki;

  const _WikiPage({required this.entity, required this.wiki});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar(entity.displayTitle, leadingEntity: entity),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Text(wiki.content),
            const SizedBox(height: 10),
            SafeArea(
              child: Text(
                'Published ${wiki.published}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
}
