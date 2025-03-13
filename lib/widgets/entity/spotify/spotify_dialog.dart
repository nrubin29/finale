import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:flutter/material.dart';

class SpotifyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(SocialMediaIcons.spotify),
          SizedBox(width: 10),
          Text('Spotify Search'),
        ],
      ),
      content: const Text(
        'Sign in with your Spotify account to search and scrobble from '
        'Spotify\'s database. Spotify\'s database is much cleaner than '
        'Last.fm\'s, but it may not have some tracks.\n\nIf you don\'t want '
        'to use this feature, you can disable it in the in-app settings.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('Sign in'),
          onPressed: () async {
            final result = await Spotify.authenticate();
            if (!context.mounted) return;
            Navigator.pop(context, result);
          },
        ),
      ],
    );
  }
}
