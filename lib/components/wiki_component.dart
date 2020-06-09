import 'package:flutter/material.dart';
import 'package:simplescrobble/types/lcommon.dart';

class WikiComponent extends StatelessWidget {
  final LWiki wiki;

  WikiComponent({Key key, @required this.wiki}) : super(key: key);

  Widget _buildPage(BuildContext context) => Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Wiki')),
      body: ListView(padding: EdgeInsets.all(10), children: [
        Text(wiki.content.substring(0, wiki.content.indexOf('<a')).trim()),
        SizedBox(height: 10),
        SafeArea(
            child: Text('Published ${wiki.published}',
                style: Theme.of(context).textTheme.caption))
      ]));

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(wiki.summary.trim(),
          maxLines: 3, overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: _buildPage));
      });
}
