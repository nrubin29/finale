import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Listen Continuously Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListTile(
            title: 'Strip tags',
            description:
                'Removes tags like (Live) or [Demo] from track titles. This '
                'can help with double scrobbles when the continuous scrobbler '
                'finds multiple names for the same track.',
            icon: Icons.label_off,
            value: _stripTags,
            onChanged: (value) {
              setState(() {
                _stripTags = (Preferences().stripTags = value);
              });
            },
          ),
          SettingsListTile(
            title: 'Listen more frequently',
            description:
                'Listens every 30 seconds instead of every minute. This will '
                'ensure that shorter songs are not missed, but it will use '
                'slightly more battery and data.',
            icon: Icons.more_time,
            value: _listenMoreFrequently,
            onChanged: (value) {
              setState(() {
                _listenMoreFrequently =
                    (Preferences().listenMoreFrequently = value);
              });
            },
          ),
        ],
      ),
    );
  }
}
