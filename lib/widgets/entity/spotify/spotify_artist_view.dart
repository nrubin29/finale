import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/artist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/artist_tabs.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/spotify/spotify_album_view.dart';
import 'package:flutter/material.dart';

class SpotifyArtistView extends StatelessWidget {
  final dynamic /* SArtist|SArtistSimple */ artist;

  const SpotifyArtistView({required this.artist})
    : assert(artist is SArtist || artist is SArtistSimple);

  @override
  Widget build(BuildContext context) => FutureBuilderView<SArtist>(
    futureFactory:
        artist is SArtist
            ? () => Future.value(artist)
            : () => Spotify.getFullArtist(artist),
    baseEntity: artist,
    builder:
        (artist) => Scaffold(
          appBar: createAppBar(
            context,
            artist.name,
            backgroundColor: spotifyGreen,
          ),
          body: TwoUp(
            entity: artist,
            listItems: [
              ArtistTabs(
                color: spotifyGreen,
                albumsWidget: EntityDisplay<SAlbumSimple>(
                  scrollable: false,
                  request: SArtistAlbumsRequest(artist),
                  detailWidgetBuilder:
                      (album) => SpotifyAlbumView(album: album),
                ),
                tracksWidget: FutureBuilderView<List<STrack>>(
                  futureFactory: () => Spotify.getTopTracksForArtist(artist),
                  baseEntity: artist,
                  isView: false,
                  builder:
                      (tracks) => EntityDisplay<STrack>(
                        scrollable: false,
                        items: tracks,
                        scrobbleableEntity: (track) => Future.value(track),
                      ),
                ),
              ),
            ],
          ),
        ),
  );
}
