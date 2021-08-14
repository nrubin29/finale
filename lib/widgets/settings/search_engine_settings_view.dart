import 'package:finale/env.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SearchEngineSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchEngineSettingsViewState();
}

class _SearchEngineSettingsViewState extends State<SearchEngineSettingsView> {
  late bool _spotifyEnabled;
  late bool _libreEnabled;

  @override
  void initState() {
    super.initState();
    _spotifyEnabled = Preferences().spotifyEnabled;
    _libreEnabled = Preferences().libreEnabled;
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
                            builder: (context) => SpotifyDialog());
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
        ListTile(
          title: Row(children: const [Text('Libre.fm')]),
          leading: const Icon(Icons.rss_feed),
          trailing: Switch(
            value: _libreEnabled,
            onChanged: (value) async {
              if (value && Preferences().libreKey == null) {
                try {
                  final result = await FlutterWebAuth.authenticate(
                      url: Uri.https('libre.fm', 'api/auth', {
                        'api_key': apiKey,
                        'cb': authCallbackUrl
                      }).toString(),
                      callbackUrlScheme: 'finale');
                  final token = Uri.parse(result).queryParameters['token']!;
                  final session = await Lastfm.authenticate(token, libre: true);
                  Preferences().libreKey = session.key;
                } on PlatformException catch (e) {
                  assert(() {
                    throw e;
                  }());
                  return;
                }
              }

              _libreEnabled = (Preferences().libreEnabled = value);

              setState(() {
                if (!_libreEnabled) {
                  Preferences().clearLibre();
                }
              });
            },
          ),
        ),
      ]),
    );
  }
}
