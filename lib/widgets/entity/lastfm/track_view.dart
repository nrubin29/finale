import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/future_builder_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/love_button.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/tag_chips.dart';
import 'package:finale/widgets/entity/lastfm/wiki_view.dart';
import 'package:finale/widgets/entity/lastfm/your_scrobbles_view.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TrackView extends StatelessWidget {
  final Track track;

  const TrackView({required this.track});

  @override
  Widget build(BuildContext context) => FutureBuilderView<LTrack>(
        future: track is LTrack
            ? Future.value(track as LTrack)
            : Lastfm.getTrack(track),
        baseEntity: track,
        builder: (track) => Scaffold(
          appBar: createAppBar(
            track.name,
            subtitle: track.artist?.name,
            actions: [
              IconButton(
                icon: Icon(Icons.adaptive.share),
                onPressed: () {
                  Share.share(track.url);
                },
              ),
              ScrobbleButton(entity: track),
            ],
          ),
          body: TwoUp(
            entity: track,
            listItems: [
              Scoreboard(
                statistics: {
                  'Scrobbles': track.playCount,
                  'Listeners': track.listeners,
                  'Your scrobbles': track.userPlayCount,
                  if (track.userPlayCount > 0 && track.duration > 0)
                    'Total listen time': formatDuration(Duration(
                        milliseconds: track.userPlayCount * track.duration)),
                },
                statisticActions: {
                  if (track.userPlayCount > 0)
                    'Your scrobbles': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YourScrobblesView(track: track),
                        ),
                      );
                    },
                },
                actions: [
                  LoveButton(track: track),
                ],
              ),
              if (track.topTags.tags.isNotEmpty) ...[
                const Divider(),
                TagChips(topTags: track.topTags),
              ],
              if (track.wiki != null && track.wiki!.isNotEmpty) ...[
                const Divider(),
                WikiTile(entity: track, wiki: track.wiki!),
              ],
              if (track.artist != null || track.album != null) const Divider(),
              if (track.artist != null)
                ListTile(
                  leading: EntityImage(entity: track.artist!),
                  title: Text(track.artist!.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ArtistView(artist: track.artist!)));
                  },
                ),
              if (track.album != null)
                ListTile(
                  leading: EntityImage(entity: track.album!),
                  title: Text(track.album!.name),
                  subtitle:
                      track.artist != null ? Text(track.artist!.name) : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AlbumView(album: track.album!)),
                    );
                  },
                ),
            ],
          ),
        ),
      );
}
