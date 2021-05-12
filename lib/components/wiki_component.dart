import 'package:finale/services/lastfm/common.dart';
import 'package:flutter/material.dart';

class WikiComponent extends StatelessWidget {
  final LWiki wiki;

  WikiComponent({required this.wiki});

  Widget _buildPage(BuildContext context) => Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Wiki')),
      body: ListView(padding: EdgeInsets.all(10), children: [
        Text(wiki.content),
        SizedBox(height: 10),
        SafeArea(
            child: Text('Published ${wiki.published}',
                style: Theme.of(context).textTheme.caption))
      ]));

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(wiki.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: _buildPage));
      });
}
