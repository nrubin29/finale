import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/settings/profile_tabs_settings_view.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('General Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListTile(
            title: 'Show album artist field',
            description:
                'Enable to show the album artist field in the scrobbler.',
            icon: Icons.people,
            preference: Preferences.showAlbumArtistField,
          ),
          SettingsListTile(
            title: 'Input dates/times as text',
            description:
                'If enabled, date/time inputs will default to using text '
                'fields rather than calendars/clocks.',
            icon: Icons.date_range,
            preference: Preferences.inputDateTimeAsText,
          ),
          CaptionedListTile(
            title: 'Profile tabs',
            caption: 'Reorder and show/hide the tabs on the profile page.',
            icon: Icons.list,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfileTabsSettingsView()),
              );
            },
          ),
        ],
      ),
    );
  }
}
