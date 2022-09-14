import 'package:finale/env.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/settings/apple_music_settings_view.dart';
import 'package:finale/widgets/settings/spotify_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:universal_io/io.dart';

class AccountsSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountsSettingsViewState();
}

class _AccountsSettingsViewState extends State<AccountsSettingsView> {
  late bool _isLibreEnabled;

  @override
  void initState() {
    super.initState();
    _isLibreEnabled = Preferences.libreEnabled.value;
  }

  @override
  Widget build(BuildContext context) {
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
          CaptionedListTile(
            title: 'Spotify',
            icon: SocialMediaIcons.spotify,
            trailing: const Icon(Icons.chevron_right),
            caption:
                'Search and scrobble from the Spotify database and ensure that '
                'your Spotify listens are being scrobbled.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SpotifySettingsView()),
              );
            },
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
            caption: 'Send all scrobbles to Libre.fm in addition to Last.fm.',
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
