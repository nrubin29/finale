import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:simplescrobble/components/display_component.dart';
import 'package:simplescrobble/components/error_component.dart';
import 'package:simplescrobble/components/image_component.dart';
import 'package:simplescrobble/components/loading_component.dart';
import 'package:simplescrobble/components/tags_component.dart';
import 'package:simplescrobble/components/wiki_component.dart';
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
          return ErrorComponent(error: snapshot.error);
        } else if (!snapshot.hasData) {
          return LoadingComponent();
        }

        final artist = snapshot.data;

        return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(artist.name),
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(artist.url);
                  },
                ),
              ],
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
                if (artist.topTags.tags.isNotEmpty) Divider(),
                if (artist.topTags.tags.isNotEmpty)
                  TagsComponent(topTags: artist.topTags),
                if (artist.bio != null) Divider(),
                if (artist.bio != null) WikiComponent(wiki: artist.bio),
                Divider(),
                TabBar(
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red,
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
