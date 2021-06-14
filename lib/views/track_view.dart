import 'dart:math';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/scoreboard_component.dart';
import 'package:finale/components/tags_component.dart';
import 'package:finale/components/wiki_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/loading_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class TrackView extends StatefulWidget {
  final Track track;

  TrackView({required this.track});

  @override
  State<StatefulWidget> createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  late bool loved;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LTrack>(
      future: Lastfm.getTrack(widget.track),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final isTrackNotFoundError = snapshot.error is LException &&
              (snapshot.error as LException).code == 6;

          return ErrorView(
            error: isTrackNotFoundError ? 'Track not found' : snapshot.error!,
            stackTrace: snapshot.stackTrace!,
            entity: widget.track,
            showSendFeedbackButton: !isTrackNotFoundError,
          );
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final track = snapshot.data!;
        loved = track.userLoved;

        return Scaffold(
            appBar: createAppBar(
              track.name,
              subtitle: track.artist?.name,
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(track.url);
                  },
                ),
                Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            final result = await showBarModalBottomSheet<bool>(
                                context: context,
                                duration: Duration(milliseconds: 200),
                                builder: (context) => ScrobbleView(
                                      track: track,
                                      isModal: true,
                                    ));

                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(result
                                      ? 'Scrobbled successfully!'
                                      : 'An error occurred while scrobbling')));
                            }
                          },
                        ))
              ],
            ),
            body: ListView(
              shrinkWrap: true,
              children: [
                if (track.album != null)
                  Center(
                      child: ImageComponent(
                          entity: track.album!,
                          fit: BoxFit.cover,
                          width: min(MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height / 2))),
                SizedBox(height: 10),
                ScoreboardComponent(
                  statistics: {
                    'Scrobbles': track.playCount,
                    'Listeners': track.listeners,
                    'Your scrobbles': track.userPlayCount,
                  },
                  actions: [
                    IconButton(
                      icon:
                          Icon(loved ? Icons.favorite : Icons.favorite_border),
                      onPressed: () async {
                        if (await Lastfm.love(track, !loved)) {
                          setState(() {
                            loved = !loved;
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (track.topTags.tags.isNotEmpty) Divider(),
                if (track.topTags.tags.isNotEmpty)
                  TagsComponent(topTags: track.topTags),
                if (track.wiki != null && track.wiki!.isNotEmpty) ...[
                  Divider(),
                  WikiComponent(wiki: track.wiki!),
                ],
                if (track.artist != null || track.album != null) Divider(),
                if (track.artist != null)
                  ListTile(
                      leading: ImageComponent(entity: track.artist!),
                      title: Text(track.artist!.name),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ArtistView(artist: track.artist!)));
                      }),
                if (track.album != null)
                  ListTile(
                    leading: ImageComponent(entity: track.album!),
                    title: Text(track.album!.name),
                    subtitle:
                        track.artist != null ? Text(track.artist!.name) : null,
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AlbumView(album: track.album!)));
                    },
                  ),
              ],
            ));
      },
    );
  }
}
