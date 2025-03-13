import 'package:finale/services/spotify/spotify.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CollageWebWarningDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning),
          SizedBox(width: 10),
          Text('Top Artists on the Web'),
        ],
      ),
      content: const Text(
        "Due to a Last.fm limitation, artist images can't be loaded on the "
        'web. You can download the app on iOS or Android to bypass this '
        'limitation, or you can sign in with Spotify and Finale will attempt '
        'to find images for your artists.',
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('Download Finale for Mobile'),
          onPressed: () async {
            await launchUrl(Uri.https('finale.app', ''));
            if (!context.mounted) return;
            Navigator.pop(context, false);
          },
        ),
        TextButton(
          child: const Text('Sign in with Spotify'),
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
