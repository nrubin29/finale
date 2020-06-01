import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/components/display_component.dart';
import 'package:simplescrobble/components/tags_component.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lalbum.dart';
import 'package:simplescrobble/views/artist_view.dart';

class AlbumView extends StatelessWidget {
  final BasicAlbum album;

  AlbumView({Key key, @required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LAlbum>(
      future: Lastfm.getAlbum(album),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final album = snapshot.data;

        return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text(album.name),
                  Text(
                    album.artist.name,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
            body: ListView(
              children: [
                if (album.images != null)
                  Image.network(album.images.last.url, fit: BoxFit.cover),
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
                Divider(),
                TagsComponent(topTags: album.topTags),
                if (album.artist != null) Divider(),
                if (album.artist != null)
                  ListTile(
                      leading: FutureBuilder<List<GenericImage>>(
                        future: album.artist.images,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.network(snapshot.data.first.url);
                          }

                          return SizedBox();
                        },
                      ),
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
                  Expanded(
                      child: DisplayComponent(
                    items: album.tracks,
                    displayNumbers: true,
                  )),
              ],
            ));
      },
    );
  }
}
