import 'dart:math';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/entity_display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/components/tags_component.dart';
import 'package:finale/components/wiki_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/album.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';

class AlbumView extends StatelessWidget {
  final BasicAlbum album;

  AlbumView({required this.album});

  @override
  Widget build(BuildContext context) {
    Lastfm.getAlbum(album);

    return FutureBuilder<LAlbum>(
      future: Lastfm.getAlbum(album),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(error: snapshot.error!);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final album = snapshot.data!;

        return Scaffold(
            appBar: createAppBar(
              album.name,
              subtitle: album.artist.name,
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(album.url);
                  },
                ),
                if (album.canScrobble)
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () async {
                        final result = await showBarModalBottomSheet<bool>(
                            context: context,
                            duration: Duration(milliseconds: 200),
                            builder: (context) =>
                                ScrobbleAlbumView(album: album));

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result
                                  ? 'Scrobbled successfully!'
                                  : 'An error occurred while scrobbling')));
                        }
                      },
                    ),
                  )
              ],
            ),
            body: ListView(
              children: [
                Center(
                    child: ImageComponent(
                        entity: album,
                        fit: BoxFit.cover,
                        width: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2))),
                SizedBox(height: 10),
                IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Scrobbles'),
                        Text(formatNumber(album.playCount))
                      ],
                    ),
                    VerticalDivider(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Listeners'),
                        Text(formatNumber(album.listeners))
                      ],
                    ),
                    VerticalDivider(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Your scrobbles'),
                        Text(formatNumber(album.userPlayCount))
                      ],
                    ),
                  ],
                )),
                if (album.topTags.tags.isNotEmpty) Divider(),
                if (album.topTags.tags.isNotEmpty)
                  TagsComponent(topTags: album.topTags),
                if (album.wiki != null && album.wiki!.isNotEmpty) ...[
                  Divider(),
                  WikiComponent(wiki: album.wiki!)
                ],
                Divider(),
                ListTile(
                    leading: ImageComponent(entity: album.artist),
                    title: Text(album.artist.name),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ArtistView(artist: album.artist)));
                    }),
                if (album.tracks.isNotEmpty) Divider(),
                if (album.tracks.isNotEmpty)
                  EntityDisplayComponent<LAlbumTrack>(
                    items: album.tracks,
                    scrollable: false,
                    displayNumbers: true,
                    displayImages: false,
                    detailWidgetBuilder: (track) => TrackView(track: track),
                  ),
              ],
            ));
      },
    );
  }
}
