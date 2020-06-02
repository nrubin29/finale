import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/components/display_component.dart';
import 'package:simplescrobble/components/image_component.dart';
import 'package:simplescrobble/components/tags_component.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';
import 'package:simplescrobble/types/lartist.dart';

class ArtistView extends StatefulWidget {
  final BasicArtist artist;

  ArtistView({Key key, @required this.artist}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LArtist>(
      future: Lastfm.getArtist(widget.artist),
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
            body: ListView(
              children: [
                ImageComponent(displayable: artist, fit: BoxFit.cover),
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
                Divider(),
                TagsComponent(topTags: artist.topTags),
                Divider(),
                TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(icon: Icon(Icons.album)),
                      Tab(icon: Icon(Icons.audiotrack)),
                    ],
                    onTap: (index) {
                      setState(() {
                        selectedIndex = index;
                        _tabController.animateTo(index);
                      });
                    }),
                IndexedStack(index: selectedIndex, children: [
                  Visibility(
                    visible: selectedIndex == 0,
                    maintainState: true,
                    child: DisplayComponent(
                        request: ArtistGetTopAlbumsRequest(artist.name)),
                  ),
                  Visibility(
                    visible: selectedIndex == 1,
                    maintainState: true,
                    child: DisplayComponent(
                        request: ArtistGetTopTracksRequest(artist.name)),
                  ),
                ])
//                DefaultTabController(
//                    length: 2,
//                    child: Column(children: [
//                      TabBar(tabs: [
//                        Tab(icon: Icon(Icons.album)),
//                        Tab(icon: Icon(Icons.audiotrack)),
//                      ]),
//                      Expanded(
//                          child: TabBarView(children: [
//                        DisplayComponent(
//                            request: ArtistGetTopAlbumsRequest(artist.name)),
//                        DisplayComponent(
//                            request: ArtistGetTopAlbumsRequest(artist.name)),
//                      ]))
//                    ]))
              ],
            ));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
