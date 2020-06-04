import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:simplescrobble/components/image_component.dart';
import 'package:simplescrobble/components/tags_component.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/ltrack.dart';
import 'package:simplescrobble/views/album_view.dart';
import 'package:simplescrobble/views/artist_view.dart';
import 'package:simplescrobble/views/scrobble_view.dart';

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
          return Center(child: CircularProgressIndicator());
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
              actions: [
                Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            final result = await showBarModalBottomSheet<bool>(
                                context: context,
                                duration: Duration(milliseconds: 200),
                                builder: (context, controller) => ScrobbleView(
                                      track: track,
                                      isModal: true,
                                    ));

                            if (result != null) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(result
                                      ? 'Scrobbled successfully!'
                                      : 'An error occurred while scrobbling')));
                            }
                          },
                        ))
              ],
            ),
            body: ListView(
              children: [
                if (track.album != null)
                  ImageComponent(
                      displayable: track.album,
                      quality: ImageQuality.high,
                      fit: BoxFit.cover),
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
                Divider(),
                TagsComponent(topTags: track.topTags),
                Divider(),
                if (track.artist != null)
                  ListTile(
                      leading: ImageComponent(displayable: track.artist),
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
                    leading: ImageComponent(displayable: track.album),
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
            ));
      },
    );
  }
}
