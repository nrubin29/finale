import 'package:finale/components/spotify_dialog_component.dart';
import 'package:finale/constants.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SearchEngineSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchEngineSettingsViewState();
}

class _SearchEngineSettingsViewState extends State<SearchEngineSettingsView> {
  var _spotifyEnabled = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    _spotifyEnabled =
        (await SharedPreferences.getInstance()).getBool('spotifyEnabled') ??
            true;
    setState(() {});
  }

  void _logOutSpotify() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('spotifyAccessToken');
    sharedPreferences.remove('spotifyRefreshToken');
    sharedPreferences.remove('spotifyExpiration');
    setState(() {
      SearchView.spotifyEnabledChanged.add(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Engines')),
      body: Column(children: [
        ListTile(
          title: Text('Last.fm'),
          leading: getLastfmIcon(Colors.grey),
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
              FutureBuilder<bool>(
                future: Spotify.hasAuthData,
                initialData: false,
                builder: (context, snapshot) => snapshot.data
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
              ),
            ],
          ]),
          leading: Icon(SocialMediaIcons.spotify),
          trailing: Switch(
            value: _spotifyEnabled,
            onChanged: (_) async {
              (await SharedPreferences.getInstance())
                  .setBool('spotifyEnabled', !_spotifyEnabled);
              _spotifyEnabled = !_spotifyEnabled;

              if (!_spotifyEnabled) {
                _logOutSpotify();
              } else {
                SearchView.spotifyEnabledChanged.add(null);
                setState(() {});
              }
            },
          ),
        ),
      ]),
    );
  }
}
