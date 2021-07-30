import 'package:finale/services/spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:social_media_buttons/social_media_icons.dart';

class SpotifyDialogComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(children: [
        Icon(SocialMediaIcons.spotify),
        SizedBox(width: 10),
        Text('Spotify Search')
      ]),
      content: Text(
          'Sign in with your Spotify account to search and scrobble from '
          'Spotify\'s database. Spotify\'s database is much cleaner than '
          'Last.fm\'s, but it may not have some tracks.\n\nIf you don\'t want '
          'to use this feature, you can disable it in the in-app settings.'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text('Sign in'),
          onPressed: () async {
            Navigator.pop(context, await Spotify.authenticate());
          },
        ),
      ],
    );
  }
}
