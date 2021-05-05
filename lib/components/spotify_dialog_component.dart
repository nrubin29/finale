import 'package:finale/services/spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SpotifyDialogComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [Icon(SocialMediaIcons.spotify), SizedBox(width: 5), Text('Spotify')]),
      content:
          Text('Sign in with your Spotify account to search and scrobble from '
              'Spotify\'s database. Spotify\'s database is much cleaner than '
              'Last.fm\'s, but it may not have some tracks.'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Sign in'),
          onPressed: () async {
            final pkcePair = PkcePair.generate();
            final result = await FlutterWebAuth.authenticate(
                url: Spotify.createAuthorizationUri(pkcePair).toString(),
                callbackUrlScheme: 'finale');
            final code = Uri.parse(result).queryParameters['code'];

            if (code != null) {
              final response = await Spotify.getAccessToken(code, pkcePair);
              final sharedPreferences = await SharedPreferences.getInstance();
              sharedPreferences.setString(
                  'spotifyAccessToken', response.accessToken);
              sharedPreferences.setString(
                  'spotifyRefreshToken', response.refreshToken);
              sharedPreferences.setInt(
                  'spotifyExpiration',
                  DateTime.now()
                      .add(Duration(seconds: response.expiresIn))
                      .millisecondsSinceEpoch);
              print('Got access token ${response.accessToken}');
            }
          },
        ),
      ],
    );
  }
}
