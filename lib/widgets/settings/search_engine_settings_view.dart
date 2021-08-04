import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog_component.dart';
import 'package:flutter/material.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SearchEngineSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchEngineSettingsViewState();
}

class _SearchEngineSettingsViewState extends State<SearchEngineSettingsView> {
  late bool _spotifyEnabled;

  @override
  void initState() {
    super.initState();
    _spotifyEnabled = Preferences().spotifyEnabled;
  }

  void _logOutSpotify() {
    setState(() {
      Preferences().clearSpotify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Engines')),
      body: Column(children: [
        ListTile(
          title: Text('Last.fm'),
          leading: getLastfmIcon(
              Theme.of(context).brightness == Brightness.light
                  ? Colors.black45
                  : Colors.white),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
          ),
        ),
        ListTile(
          title: Row(children: [
            Text('Spotify'),
            if (_spotifyEnabled) ...[
              SizedBox(width: 20),
              Preferences().hasSpotifyAuthData
                  ? TextButton(
                      child: Text('Log Out'),
                      onPressed: _logOutSpotify,
                    )
                  : TextButton(
                      child: Text('Log In'),
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            builder: (context) => SpotifyDialogComponent());
                        setState(() {});
                      },
                    ),
            ],
          ]),
          leading: Icon(SocialMediaIcons.spotify),
          trailing: Switch(
            value: _spotifyEnabled,
            onChanged: (_) async {
              _spotifyEnabled =
                  (Preferences().spotifyEnabled = !_spotifyEnabled);

              if (!_spotifyEnabled) {
                _logOutSpotify();
              } else {
                setState(() {});
              }
            },
          ),
        ),
      ]),
    );
  }
}
