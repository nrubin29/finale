import 'package:finale/env.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog.dart';
import 'package:finale/widgets/settings/apple_music_settings_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountsSettingsViewState();
}

class _AccountsSettingsViewState extends State<AccountsSettingsView> {
  late bool _isSpotifyEnabled;
  late bool _isLibreEnabled;

  @override
  void initState() {
    super.initState();
    _isSpotifyEnabled = Preferences.spotifyEnabled.value;
    _isLibreEnabled = Preferences.libreEnabled.value;
  }

  void _logOutSpotify() {
    setState(() {
      Preferences.clearSpotify();
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
          CaptionedListTile(
            title: 'Last.fm',
            icon: SocialMediaIcons.lastfm,
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
          CaptionedListTile.advanced(
            title: Row(children: [
              const Text('Spotify'),
              if (_isSpotifyEnabled) ...[
                const SizedBox(width: 20),
                Preferences.hasSpotifyAuthData
                    ? TextButton(
                        onPressed: _logOutSpotify,
                        child: const Text('Log Out'),
                      )
                    : TextButton(
                        onPressed: () async {
                          await showDialog(
                              context: context,
                              builder: (context) => SpotifyDialog());
                          setState(() {});
                        },
                        child: const Text('Log In'),
                      ),
              ],
            ]),
            icon: SocialMediaIcons.spotify,
            trailing: Switch(
              value: _isSpotifyEnabled,
              onChanged: (_) async {
                _isSpotifyEnabled =
                    (Preferences.spotifyEnabled.value = !_isSpotifyEnabled);

                if (!_isSpotifyEnabled) {
                  _logOutSpotify();
                } else {
                  setState(() {});
                }
              },
            ),
            caption: [
              const TextSpan(
                text: 'Sign in with your Spotify account to search and '
                    "scrobble from Spotify's database. Finale does not "
                    'automatically scrobble from Spotify, but you can connect '
                    'your Spotify account to Last.fm ',
              ),
              TextSpan(
                text: 'on the web',
                style: TextStyle(color: theme.primaryColor),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(Uri.https('last.fm', 'settings/applications'));
                  },
              ),
              const TextSpan(text: '.'),
            ],
          ),
          if (Platform.isIOS)
            CaptionedListTile(
              title: 'Apple Music',
              icon: SocialMediaIcons.apple,
              trailing: const Icon(Icons.chevron_right),
              caption: 'Scrobble music that you listen to in the Music app.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AppleMusicSettingsView()),
                );
              },
            ),
          CaptionedListTile(
            title: 'Libre.fm',
            icon: Icons.rss_feed,
            caption:
                'Sign in with your Libre.fm account to send all scrobbles to '
                'Libre.fm in addition to Last.fm.',
            trailing: Switch(
              value: _isLibreEnabled,
              onChanged: (value) async {
                if (value && Preferences.libreKey.value == null) {
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
                    Preferences.libreKey.value = session.key;
                  } on PlatformException {
                    if (isDebug) {
                      rethrow;
                    }
                    return;
                  }
                }

                _isLibreEnabled = (Preferences.libreEnabled.value = value);

                setState(() {
                  if (!_isLibreEnabled) {
                    Preferences.clearLibre();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
