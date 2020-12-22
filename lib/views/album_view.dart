import 'dart:math';

import 'package:finale/components/display_component.dart';
import 'package:finale/components/error_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/loading_component.dart';
import 'package:finale/components/tags_component.dart';
import 'package:finale/components/wiki_component.dart';
import 'package:finale/lastfm.dart';
import 'package:finale/types/generic.dart';
import 'package:finale/types/lalbum.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';

class AlbumView extends StatelessWidget {
  final BasicAlbum album;

  AlbumView({Key key, @required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LAlbum>(
      future: Lastfm.getAlbum(album),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorComponent(error: snapshot.error);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final album = snapshot.data;

        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Column(
                children: [
                  Text(album.name),
                  Text(
                    album.artist.name,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(album.url);
                  },
                ),
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
                        Scaffold.of(context).showSnackBar(SnackBar(
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
                        displayable: album,
                        quality: ImageQuality.high,
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
                if (album.wiki != null) Divider(),
                if (album.wiki != null) WikiComponent(wiki: album.wiki),
                if (album.artist != null) Divider(),
                if (album.artist != null)
                  ListTile(
                      leading: ImageComponent(displayable: album.artist),
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
                  DisplayComponent(
                    items: album.tracks,
                    scrollable: false,
                    displayNumbers: true,
                    displayImages: false,
                  ),
              ],
            ));
      },
    );
  }
}
