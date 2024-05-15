import 'dart:math';

import 'package:finale/env.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/main/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class LoginView extends StatelessWidget {
  const LoginView();

  static void logOutAndShow(BuildContext context) {
    Preferences.clearLastfm();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _logIn(BuildContext context) async {
    final result = await FlutterWebAuth.authenticate(
        url: Uri.https('last.fm', 'api/auth',
            {'api_key': apiKey, 'cb': authCallbackUrl}).toString(),
        callbackUrlScheme: 'finale');
    final token = Uri.parse(result).queryParameters['token']!;
    final session = await Lastfm.authenticate(token);

    Preferences.name.value = session.name;
    Preferences.key.value = session.key;

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainView(username: session.name)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FutureBuilder<List<LTopArtistsResponseArtist>>(
            future: Lastfm.getGlobalTopArtists(50),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              return GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisCount:
                    max(MediaQuery.of(context).size.width ~/ 200, 3),
                children: snapshot.data!
                    .map((artist) => FutureBuilder<List<LArtistTopAlbum>>(
                        future: ArtistGetTopAlbumsRequest(artist.name)
                            .getData(1, 1),
                        builder: (context, snapshot) => snapshot.hasData
                            ? EntityImage(
                                entity: snapshot.data!.first,
                                quality: ImageQuality.high,
                                placeholderBehavior: PlaceholderBehavior.none,
                              )
                            : Container()))
                    .toList(),
              );
            },
          ),
          Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(2 / 3))),
          Center(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.9),
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Finale',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('A fully-featured Last.fm client and scrobbler',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _logIn(context),
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(SocialMediaIcons.lastfm,
                            color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Log in with Last.fm',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.white))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
