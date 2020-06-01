import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/ltrack.dart';

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
                          Text(track.playCountFormatted)
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Listeners'),
                          Text(track.listenersFormatted)
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Your scrobbles'),
                          Text(track.userPlayCountFormatted)
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
                      title: Text(track.artist.name),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  if (track.album != null)
                    ListTile(
                      leading: Image.network(track.album.images.last.url),
                      title: Text(track.album.name),
                      subtitle: Text(track.artist.name),
                      trailing: Icon(Icons.chevron_right),
                    ),
                ],
              ),
            ));
      },
    );
  }
}
