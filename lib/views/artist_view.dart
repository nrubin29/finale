import 'dart:math';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/entity_display_component.dart';
import 'package:finale/components/image_component.dart';
import 'package:finale/components/scoreboard_component.dart';
import 'package:finale/components/tags_component.dart';
import 'package:finale/components/wiki_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/loading_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArtistView extends StatefulWidget {
  final BasicArtist artist;

  ArtistView({required this.artist});

  @override
  State<StatefulWidget> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var selectedIndex = 0;

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
          return ErrorView(
            error: snapshot.error!,
            stackTrace: snapshot.stackTrace!,
            entity: widget.artist,
          );
        } else if (!snapshot.hasData) {
          return LoadingView();
        }

        final artist = snapshot.data!;

        return Scaffold(
            appBar: createAppBar(
              artist.name,
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
                Center(
                    child: ImageComponent(
                        entity: artist,
                        fit: BoxFit.cover,
                        width: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height / 2))),
                SizedBox(height: 10),
                ScoreboardComponent(statistics: {
                  'Scrobbles': artist.stats.playCount,
                  'Listeners': artist.stats.listeners,
                  'Your scrobbles': artist.stats.userPlayCount,
                }),
                if (artist.topTags.tags.isNotEmpty) Divider(),
                if (artist.topTags.tags.isNotEmpty)
                  TagsComponent(topTags: artist.topTags),
                if (artist.bio != null && artist.bio!.isNotEmpty) ...[
                  Divider(),
                  WikiComponent(wiki: artist.bio!),
                ],
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
                    child: EntityDisplayComponent<LArtistTopAlbum>(
                        scrollable: false,
                        request: ArtistGetTopAlbumsRequest(artist.name),
                        detailWidgetBuilder: (album) =>
                            AlbumView(album: album)),
                  ),
                  Visibility(
                    visible: selectedIndex == 1,
                    maintainState: true,
                    child: EntityDisplayComponent<LArtistTopTrack>(
                        scrollable: false,
                        request: ArtistGetTopTracksRequest(artist.name),
                        detailWidgetBuilder: (track) =>
                            TrackView(track: track)),
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
