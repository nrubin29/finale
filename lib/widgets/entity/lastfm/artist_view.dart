import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/artist_tabs.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/tag_chips.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/lastfm/wiki_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArtistView extends StatelessWidget {
  final BasicArtist artist;

  const ArtistView({required this.artist});

  @override
  Widget build(BuildContext context) => FutureBuilderView<LArtist>(
        futureFactory: artist is LArtist
            ? () => Future.value(artist as LArtist)
            : () => Lastfm.getArtist(artist),
        baseEntity: artist,
        builder: (artist) => Scaffold(
          appBar: createAppBar(
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
              Scoreboard(statistics: {
                'Scrobbles': artist.stats.playCount,
                'Listeners': artist.stats.listeners,
                'Your scrobbles': artist.stats.userPlayCount,
              }),
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
              ),
            ],
          ),
        ),
      );
}
