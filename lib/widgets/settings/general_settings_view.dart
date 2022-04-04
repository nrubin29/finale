import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/settings/profile_tabs_settings_view.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';

class GeneralSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  late bool _showAlbumArtistField;
  late bool _inputDateTimeAsText;

  @override
  void initState() {
    super.initState();
    _showAlbumArtistField = Preferences().showAlbumArtistField;
    _inputDateTimeAsText = Preferences().inputDateTimeAsText;
  }

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
            value: _showAlbumArtistField,
            onChanged: (value) {
              setState(() {
                _showAlbumArtistField =
                    (Preferences().showAlbumArtistField = value);
              });
            },
          ),
          SettingsListTile(
            title: 'Input dates/times as text',
            description:
                'If enabled, date/time inputs will default to using text '
                'fields rather than calendars/clocks.',
            icon: Icons.date_range,
            value: _inputDateTimeAsText,
            onChanged: (value) {
              setState(() {
                _inputDateTimeAsText =
                    (Preferences().inputDateTimeAsText = value);
              });
            },
          ),
          CaptionedListTile(
            title: 'Profile tabs order',
            caption: 'Reorder the tabs on the profile page.',
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
