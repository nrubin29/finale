import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class ListenContinuouslySettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenContinuouslySettingsViewState();
}

class _ListenContinuouslySettingsViewState
    extends State<ListenContinuouslySettingsView> {
  late bool _stripTags;
  late bool _listenMoreFrequently;

  @override
  void initState() {
    super.initState();
    _stripTags = Preferences().stripTags;
    _listenMoreFrequently = Preferences().listenMoreFrequently;
  }

  List<Widget> _listTile(String title, String description, IconData icon,
          bool value, ValueChanged<bool> onChanged) =>
      [
        ListTile(
          title: Text(title),
          leading: Icon(icon),
          trailing: Switch(
            value: value,
            onChanged: (value) {
              setState(() {
                onChanged(value);
              });
            },
          ),
        ),
        SafeArea(
          top: false,
          bottom: false,
          minimum: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            description,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Listen Continuously Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._listTile(
            'Strip tags',
            'Removes tags like (Live) or [Demo] from track titles. This can '
                'help with double scrobbles when the continuous scrobbler '
                'finds multiple names for the same track.',
            Icons.label_off,
            _stripTags,
            (value) {
              _stripTags = (Preferences().stripTags = value);
            },
          ),
          ..._listTile(
            'Listen more frequently',
            'Listens every 30 seconds instead of every minute. This will '
                'ensure that shorter songs are not missed, but it will use '
                'slightly more battery and data.',
            Icons.more_time,
            _listenMoreFrequently,
            (value) {
              _listenMoreFrequently =
                  (Preferences().listenMoreFrequently = value);
            },
          ),
        ],
      ),
    );
  }
}
