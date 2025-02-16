import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/top_listeners_ranking.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/artist_tabs.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/profile_stack.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/tag_chips.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/lastfm/wiki_view.dart';
import 'package:finale/widgets/base/fractional_bar.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArtistView extends StatelessWidget {
  final BasicArtist artist;

  const ArtistView({required this.artist});

  @override
  Widget build(BuildContext context) {
    final friendUsername = ProfileStack.of(context).friendUsername;
    return FutureBuilderView<LArtist>(
      futureFactory: artist is LArtist
          ? () => Future.value(artist as LArtist)
          : () => Lastfm.getArtist(artist),
      baseEntity: artist,
      builder: (artist) => Scaffold(
        appBar: createAppBar(
          context,
          artist.name,
          actions: [
            IconButton(
              icon: Icon(Icons.adaptive.share),
              onPressed: () {
                Share.share(artist.url);
              },
            ),
          ],
        ),
        body: TwoUp(
          entity: artist,
          listItems: [
            Scoreboard(
              items: [
                ScoreboardItemModel.value(
                  label: 'Scrobbles',
                  value: artist.stats.playCount,
                ),
                ScoreboardItemModel.value(
                  label: 'Listeners',
                  value: artist.stats.listeners,
                ),
                ScoreboardItemModel.value(
                  label: 'Your scrobbles',
                  value: artist.stats.userPlayCount,
                ),
                if (friendUsername != null)
                  ScoreboardItemModel.future(
                    label: "$friendUsername's scrobbles",
                    futureProvider: () =>
                        Lastfm.getArtist(artist, username: friendUsername)
                            .then((value) => value.stats.userPlayCount),
                  ),
                ScoreboardItemModel.lazy(
                  label: 'Top listeners ranking',
                  futureProvider: () => fetchTopListenersRanking(artist),
                ),
              ],
            ),
            if (artist.topTags.tags.isNotEmpty) ...[
              const Divider(),
              TagChips(topTags: artist.topTags),
            ],
            if (artist.bio != null && artist.bio!.isNotEmpty) ...[
              const Divider(),
              WikiTile(entity: artist, wiki: artist.bio!),
            ],
            const Divider(),
            ArtistTabs(
              albumsWidget: EntityDisplay<LArtistTopAlbum>(
                scrollable: false,
                request: ArtistGetTopAlbumsRequest(artist.name),
                detailWidgetBuilder: (album) => AlbumView(album: album),
              ),
              tracksWidget: EntityDisplay<LArtistTopTrack>(
                scrollable: false,
                request: ArtistGetTopTracksRequest(artist.name),
                detailWidgetBuilder: (track) => TrackView(track: track),
              ),
              similarArtistsWidget: FutureBuilderView<List<LSimilarArtist>>(
                futureFactory: () => Lastfm.getSimilarArtists(artist),
                baseEntity: artist,
                isView: false,
                builder: (items) => EntityDisplay<LSimilarArtist>(
                  scrollable: false,
                  items: items,
                  detailWidgetBuilder: (artist) => ArtistView(artist: artist),
                  subtitleWidgetBuilder: (artist, _) =>
                      FractionalBar(artist.similarity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
