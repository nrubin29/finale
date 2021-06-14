import 'package:finale/components/app_bar_component.dart';
import 'package:finale/util/preferences.dart';
import 'package:flutter/material.dart';

class ListenContinuouslySettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenContinuouslySettingsViewState();
}

class _ListenContinuouslySettingsViewState
    extends State<ListenContinuouslySettingsView> {
  late bool _stripTags;

  @override
  void initState() {
    super.initState();
    _stripTags = Preferences().stripTags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Listen Continuously Settings'),
      body: Column(children: [
        ListTile(
          title: Text('Strip tags'),
          leading: Icon(Icons.label_off),
          trailing: Switch(
            value: _stripTags,
            onChanged: (_) {
              setState(() {
                _stripTags = (Preferences().stripTags = !_stripTags);
              });
            },
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
                'Removes tags like (Live) or [Demo] from track titles. This '
                'can help with double scrobbles when the continuous scrobbler '
                'finds multiple names for the same track.',
                style: Theme.of(context).textTheme.caption)),
      ]),
    );
  }
}
