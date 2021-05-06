import 'package:finale/services/spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SpotifyDialogComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Icon(SocialMediaIcons.spotify),
        SizedBox(width: 5),
        Text('Spotify Search')
      ]),
      content:
          Text('Sign in with your Spotify account to search and scrobble from '
              'Spotify\'s database. Spotify\'s database is much cleaner than '
              'Last.fm\'s, but it may not have some tracks.'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
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
              await Spotify.getAccessToken(code, pkcePair);
              Navigator.pop(context, true);
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
      ],
    );
  }
}
