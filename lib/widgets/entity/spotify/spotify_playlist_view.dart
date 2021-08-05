import 'dart:math';

import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';

class SpotifyPlaylistView extends StatelessWidget {
  final SPlaylistSimple playlist;

  SpotifyPlaylistView({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SPlaylistFull>(
      future: Spotify.getFullPlaylist(playlist),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace!,
            entity: this.playlist,
          );
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final playlist = snapshot.data!;

        return Scaffold(
            appBar: createAppBar(
              playlist.name,
              backgroundColor: spotifyGreen,
              actions: [
                if (playlist.canScrobble) ScrobbleButton(entity: playlist),
              ],
            ),
            body: ListView(
              children: [
                Center(
                    child: EntityImage(
                        entity: playlist,
                        fit: BoxFit.cover,
                        width: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2))),
                if (playlist.tracks.isNotEmpty) ...[
                  SizedBox(height: 10),
                  EntityDisplay<STrack>(
                    items: playlist.tracks,
                    scrollable: false,
                    scrobbleableEntity: (track) => track,
                  ),
                ],
              ],
            ));
      },
    );
  }
}
