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
import 'package:finale/widgets/scrobble/batch_scrobble_view.dart';
import 'package:finale/widgets/scrobble/scrobble_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
                if (playlist.canScrobble)
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(scrobbleIcon),
                      onPressed: () async {
                        await showBarModalBottomSheet(
                            context: context,
                            duration: Duration(milliseconds: 200),
                            builder: (context) =>
                                BatchScrobbleView(entity: playlist));
                      },
                    ),
                  )
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
                    secondaryAction: (track) async {
                      await showBarModalBottomSheet(
                          context: context,
                          duration: Duration(milliseconds: 200),
                          builder: (context) =>
                              ScrobbleView(track: track, isModal: true));
                    },
                  ),
                ],
              ],
            ));
      },
    );
  }
}
