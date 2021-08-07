import 'package:finale/services/lastfm/common.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class WikiTile extends StatelessWidget {
  final LWiki wiki;

  const WikiTile({required this.wiki});

  Widget _buildPage(BuildContext context) => Scaffold(
        appBar: createAppBar('Wiki'),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Text(wiki.content),
              const SizedBox(height: 10),
              Text(
                'Published ${wiki.published}',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          wiki.summary,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: _buildPage));
        },
      );
}
