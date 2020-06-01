import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/ltrack.dart';
import 'package:simplescrobble/views/album_view.dart';
import 'package:simplescrobble/views/artist_view.dart';

class TrackView extends StatelessWidget {
  final BasicTrack track;

  TrackView({Key key, @required this.track}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LTrack>(
      future: Lastfm.getTrack(track),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final track = snapshot.data;

        return Scaffold(
            appBar: AppBar(
              title: Column(
                children: [
                  Text(track.name),
                  Text(
                    track.artist.name,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  if (track.album?.images != null)
                    Image.network(track.album.images.last.url),
                  SizedBox(height: 10),
                  IntrinsicHeight(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Scrobbles'),
                          Text(formatNumber(track.playCount))
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Listeners'),
                          Text(formatNumber(track.listeners))
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Your scrobbles'),
                          Text(formatNumber(track.userPlayCount))
                        ],
                      ),
                      VerticalDivider(),
                      IconButton(
                        icon: Icon(track.userLoved
                            ? Icons.favorite
                            : Icons.favorite_border),
                        onPressed: () {},
                      ),
                    ],
                  )),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: track.topTags.tags
                            .map((tag) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: Chip(label: Text(tag.name))))
                            .toList(),
                      )),
                  if (track.artist != null)
                    ListTile(
                        leading: FutureBuilder<List<GenericImage>>(
                          future: track.artist.images,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.network(snapshot.data.first.url);
                            }

                            return SizedBox();
                          },
                        ),
                        title: Text(track.artist.name),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ArtistView(artist: track.artist)));
                        }),
                  if (track.album != null)
                    ListTile(
                      leading: Image.network(track.album.images.last.url),
                      title: Text(track.album.name),
                      subtitle: Text(track.artist.name),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    AlbumView(album: track.album)));
                      },
                    ),
                ],
              ),
            ));
      },
    );
  }
}
