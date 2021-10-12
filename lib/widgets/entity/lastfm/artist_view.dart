import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/scoreboard.dart';
import 'package:finale/widgets/entity/lastfm/tag_chips.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/lastfm/wiki_tile.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ArtistView extends StatefulWidget {
  final BasicArtist artist;

  const ArtistView({required this.artist});

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
      future: widget.artist is LArtist
          ? Future.value(widget.artist as LArtist)
          : Lastfm.getArtist(widget.artist),
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
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share(artist.url);
                  },
                ),
              ],
            ),
            body: TwoUp(
              image: EntityImage(entity: artist),
              listItems: [
                Scoreboard(statistics: {
                  'Scrobbles': artist.stats.playCount,
                  'Listeners': artist.stats.listeners,
                  'Your scrobbles': artist.stats.userPlayCount,
                }),
                if (artist.topTags.tags.isNotEmpty) ...[
                  const Divider(),
                  TagChips(topTags: artist.topTags),
                ],
                if (artist.bio != null && artist.bio!.isNotEmpty) ...[
                  const Divider(),
                  WikiTile(wiki: artist.bio!),
                ],
                const Divider(),
                TabBar(
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.red,
                    controller: _tabController,
                    tabs: const [
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
                    child: EntityDisplay<LArtistTopAlbum>(
                        scrollable: false,
                        request: ArtistGetTopAlbumsRequest(artist.name),
                        detailWidgetBuilder: (album) =>
                            AlbumView(album: album)),
                  ),
                  Visibility(
                    visible: selectedIndex == 1,
                    maintainState: true,
                    child: EntityDisplay<LArtistTopTrack>(
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
