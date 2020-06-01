import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lartist.dart';

class ArtistView extends StatelessWidget {
  final BasicArtist artist;

  ArtistView({Key key, @required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LArtist>(
      future: Lastfm.getArtist(artist),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final artist = snapshot.data;

        return Scaffold(
            appBar: AppBar(
              title: Text(artist.name),
            ),
            body: Center(
              child: Column(
                children: [
                  if (artist.images != null)
                    Image.network(artist.images.last.url),
                  SizedBox(height: 10),
                  IntrinsicHeight(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Scrobbles'),
                          Text(formatNumber(artist.stats.playCount))
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Listeners'),
                          Text(formatNumber(artist.stats.listeners))
                        ],
                      ),
                      VerticalDivider(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Your scrobbles'),
                          Text(formatNumber(artist.stats.userPlayCount))
                        ],
                      ),
                    ],
                  )),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: artist.topTags.tags
                            .map((tag) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                child: Chip(label: Text(tag.name))))
                            .toList(),
                      )),
                ],
              ),
            ));
      },
    );
  }
}
