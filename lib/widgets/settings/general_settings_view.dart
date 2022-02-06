import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/material.dart';

class GeneralSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  late bool _showAlbumArtistField;

  @override
  void initState() {
    super.initState();
    _showAlbumArtistField = Preferences().showAlbumArtistField;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('General Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsListTile(
            title: 'Show Album Artist field',
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
        ],
      ),
    );
  }
}
