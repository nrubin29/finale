import 'dart:math';
import 'dart:ui' as ui;

import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/util/web_auth.dart';
import 'package:finale/widgets/base/app_icon.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/main/main_view.dart';
import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView();

  static void logOutAndShow(BuildContext context) async {
    await Preferences.clearLastfm();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _logIn(BuildContext context) async {
    final token = await showWebAuth(
      Lastfm.authorizationUri,
      queryParam: 'token',
    );
    if (token == null) return;
    final session = await Lastfm.authenticate(token);

    Preferences.name.value = session.name;
    Preferences.key.value = session.key;

    if (!context.mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainView(username: session.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
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
                crossAxisCount: max(
                  MediaQuery.of(context).size.width ~/ 200,
                  3,
                ),
                children: snapshot.data!
                    .map(
                      (artist) => FutureBuilder<List<LArtistTopAlbum>>(
                        future: ArtistGetTopAlbumsRequest(
                          artist.name,
                        ).getData(1, 1),
                        builder: (context, snapshot) => snapshot.hasData
                            ? EntityImage(
                                entity: snapshot.data!.first,
                                quality: ImageQuality.high,
                                placeholderBehavior: PlaceholderBehavior.none,
                              )
                            : Container(),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withValues(alpha: .75),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              const AppIcon(size: 96),
              Text(
                'Finale',
                style: textTheme.displayMedium!.copyWith(color: Colors.white),
              ),
              Text(
                'A fully-featured Last.fm client and scrobbler',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  _logIn(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                icon: const Icon(SocialMediaIcons.lastfm, color: Colors.white),
                label: Text(
                  'Log in with Last.fm',
                  style: textTheme.titleMedium!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
