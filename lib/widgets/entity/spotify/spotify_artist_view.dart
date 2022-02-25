import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/artist_tabs.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/spotify/spotify_album_view.dart';
import 'package:flutter/material.dart';

class SpotifyArtistView extends StatelessWidget {
  final dynamic /* SArtist|SArtistSimple */ artist;

  const SpotifyArtistView({required this.artist})
      : assert(artist is SArtist || artist is SArtistSimple);

  @override
  Widget build(BuildContext context) => FutureBuilder<SArtist>(
        future: artist is SArtist
            ? Future.value(artist)
            : Spotify.getFullArtist(artist),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace!,
              entity: this.artist,
            );
          } else if (!snapshot.hasData) {
            return LoadingView();
          }

          final artist = snapshot.data!;

          return Scaffold(
            appBar: createAppBar(
              artist.name,
              backgroundColor: spotifyGreen,
            ),
            body: TwoUp(
              image: EntityImage(entity: artist),
              listItems: [
                ArtistTabs(
                  color: spotifyGreen,
                  albumsWidget: EntityDisplay<SAlbumSimple>(
                    scrollable: false,
                    request: SArtistAlbumsRequest(artist),
                    detailWidgetBuilder: (album) =>
                        SpotifyAlbumView(album: album),
                  ),
                  tracksWidget: FutureBuilder<List<STrack>>(
                    future: Spotify.getTopTracksForArtist(artist),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorComponent(
                          error: snapshot.error!,
                          stackTrace: snapshot.stackTrace!,
                          entity: artist,
                        );
                      } else if (!snapshot.hasData) {
                        return const LoadingComponent();
                      }

                      return EntityDisplay<STrack>(
                        scrollable: false,
                        items: snapshot.data,
                        scrobbleableEntity: (track) => Future.value(track),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
}
