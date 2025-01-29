import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';

class ListenContinuouslySettingsView extends StatelessWidget {
  const ListenContinuouslySettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, 'Listen Continuously Settings'),
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
            preference: Preferences.stripTags,
          ),
          SettingsListTile(
            title: 'Listen more frequently',
            description:
                'Listens every 30 seconds instead of every minute. This will '
                'ensure that shorter songs are not missed, but it will use '
                'slightly more battery and data.',
            icon: Icons.more_time,
            preference: Preferences.listenMoreFrequently,
          ),
        ],
      ),
    );
  }
}
