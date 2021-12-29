import 'package:finale/env.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountsSettingsViewState();
}

class _AccountsSettingsViewState extends State<AccountsSettingsView> {
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: createAppBar('Accounts'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Last.fm'),
            leading: const Icon(SocialMediaIcons.lastfm),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
          ListTile(
            title: Row(children: [
              const Text('Spotify'),
              if (_spotifyEnabled) ...[
                const SizedBox(width: 20),
                Preferences().hasSpotifyAuthData
                    ? TextButton(
                        child: const Text('Log Out'),
                        onPressed: _logOutSpotify,
                      )
                    : TextButton(
                        child: const Text('Log In'),
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (context) => SpotifyDialog());
                          setState(() {});
                        },
                      ),
              ],
            ]),
            leading: const Icon(SocialMediaIcons.spotify),
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
          SafeArea(
            top: false,
            bottom: false,
            minimum: const EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Sign in with your Spotify account to search and '
                        "scrobble from Spotify's database. Finale does not "
                        'automatically scrobble from Finale, but you can '
                        'connect your Spotify account to Last.fm ',
                    style: theme.textTheme.caption,
                  ),
                  TextSpan(
                    text: 'on the web',
                    style: theme
                        .textTheme
                        .caption
                        ?.copyWith(color: theme.primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://last.fm/settings/applications');
                      },
                  ),
                  TextSpan(
                    text: '.',
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
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
                    final session =
                        await Lastfm.authenticate(token, libre: true);
                    Preferences().libreKey = session.key;
                  } on PlatformException catch (e) {
                    assert(() {
                      // ignore: use_rethrow_when_possible
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
          SafeArea(
            top: false,
            bottom: false,
            minimum: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Sign in with your Libre.fm account to send all scrobbles to '
              'Libre.fm in addition to Last.fm.',
              style: theme.textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }
}
