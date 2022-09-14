import 'dart:async';

import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/notifications.dart' as notifications;
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/settings/settings_list_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifySettingsView extends StatefulWidget {
  const SpotifySettingsView();

  @override
  State<StatefulWidget> createState() => _SpotifySettingsViewState();
}

class _SpotifySettingsViewState extends State<SpotifySettingsView> {
  late bool _isSpotifyEnabled;
  late final StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _isSpotifyEnabled = Preferences.spotifyEnabled.value;
    _streamSubscription = Preferences.spotifyEnabled.changes.listen((value) {
      setState(() {
        _isSpotifyEnabled = value;
      });
    });
  }

  Future<void> _updateSpotifyAccount() async {
    if (Preferences.hasSpotifyAuthData) {
      setState(() {
        Preferences.clearSpotify();
      });
    } else {
      try {
        await Spotify.authenticate();
        setState(() {});
      } on PlatformException catch (e) {
        if (e.code != 'CANCELED') rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: createAppBar('Spotify Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Sign in with your Spotify account to search and '
                        "scrobble from Spotify's database. Finale does not "
                        'automatically scrobble from Spotify, but you can '
                        'connect your Spotify account to Last.fm ',
                  ),
                  TextSpan(
                    text: 'on the web',
                    style: TextStyle(color: theme.primaryColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                            Uri.https('last.fm', 'settings/applications'));
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SettingsListTile(
            title: 'Enabled',
            icon: SocialMediaIcons.spotify,
            preference: Preferences.spotifyEnabled,
          ),
          if (_isSpotifyEnabled) ...[
            ListTile(
              title: Text(
                  Preferences.hasSpotifyAuthData ? 'Logged In' : 'Account'),
              leading: const Icon(Icons.vpn_key),
              trailing: TextButton(
                onPressed: _updateSpotifyAccount,
                child:
                    Text(Preferences.hasSpotifyAuthData ? 'Log Out' : 'Log In'),
              ),
            ),
            if (Preferences.hasSpotifyAuthData && isMobile)
              SettingsListTile(
                title: 'Background Checker',
                description: 'If enabled, Finale will periodically check in the '
                    'background to ensure that your Spotify listens are '
                    "being scrobbled. If not, you'll get a notification. "
                    'Re-connecting your Spotify account often  fixes the '
                    'issue.',
                icon: Icons.youtube_searched_for,
                preference: Preferences.spotifyCheckerEnabled,
                beforeUpdate: (newValue) async {
                  if (newValue) {
                    return await notifications.requestPermission();
                  }

                  return true;
                },
              ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
