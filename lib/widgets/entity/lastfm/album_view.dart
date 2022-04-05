import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/profile_stack.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/tag_chips.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/lastfm/wiki_view.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class AlbumView extends StatelessWidget {
  final BasicAlbum album;

  const AlbumView({required this.album});

  Future<String?> _totalListenTime(LAlbum album) async {
    try {
      final tracks = await Future.wait(album.tracks.map(Lastfm.getTrack),
          eagerError: true);

      if (!tracks.every((track) => track.duration > 0)) {
        return null;
      }

      final durationMillis = tracks.fold<int>(0,
          (duration, track) => duration + track.duration * track.userPlayCount);

      return formatDuration(Duration(milliseconds: durationMillis));
    } on Exception {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendUsername = ProfileStack.of(context).friendUsername;
    return FutureBuilderView<LAlbum>(
      futureFactory: album is LAlbum
          ? () => Future.value(album as LAlbum)
          : () => Lastfm.getAlbum(album),
      baseEntity: album,
      builder: (album) => Scaffold(
        appBar: createAppBar(
          album.name,
          subtitle: album.artist.name,
          actions: [
            IconButton(
              icon: Icon(Icons.adaptive.share),
              onPressed: () {
                Share.share(album.url);
              },
            ),
            if (album.canScrobble) ScrobbleButton(entity: album),
          ],
        ),
        body: TwoUp(
          entity: album,
          listItems: [
            Scoreboard(statistics: {
              'Scrobbles': album.playCount,
              'Listeners': album.listeners,
              'Your scrobbles': album.userPlayCount,
              if (friendUsername != null)
                "$friendUsername's scrobbles":
                    Lastfm.getAlbum(album, username: friendUsername)
                        .then((value) => value.userPlayCount),
              if (album.userPlayCount > 0 && album.tracks.isNotEmpty)
                'Total listen time': _totalListenTime(album),
            }),
            if (album.topTags.tags.isNotEmpty) ...[
              const Divider(),
              TagChips(topTags: album.topTags),
            ],
            if (album.wiki != null && album.wiki!.isNotEmpty) ...[
              const Divider(),
              WikiTile(entity: album, wiki: album.wiki!),
            ],
            const Divider(),
            ListTile(
                leading: EntityImage(entity: album.artist),
                title: Text(album.artist.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ArtistView(artist: album.artist)));
                }),
            if (album.tracks.isNotEmpty) ...[
              const Divider(),
              EntityDisplay<LAlbumTrack>(
                items: album.tracks,
                scrollable: false,
                displayNumbers: true,
                displayImages: false,
                detailWidgetBuilder: (track) => TrackView(track: track),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
