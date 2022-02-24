import 'package:finale/services/apple_music/album.dart';
import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/artist.dart';
import 'package:finale/services/apple_music/song.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/error_view.dart';
import 'package:finale/widgets/base/loading_view.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_album_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class AppleMusicArtistView extends StatefulWidget {
  final String artistId;

  const AppleMusicArtistView({required this.artistId});

  @override
  State<StatefulWidget> createState() => _AppleMusicArtistViewState();
}

class _AppleMusicArtistViewState extends State<AppleMusicArtistView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AMArtist>(
        future: AppleMusic.getArtist(widget.artistId),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace!,
            );
          } else if (!snapshot.hasData) {
            return LoadingView();
          }

          final artist = snapshot.data!;

          return Scaffold(
            appBar: createAppBar(
              artist.name,
              backgroundColor: appleMusicPink,
            ),
            body: TwoUp(
              image: EntityImage(entity: artist),
              listItems: [
                TabBar(
                  labelColor: appleMusicPink,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: appleMusicPink,
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.album)),
                    Tab(icon: Icon(Icons.audiotrack)),
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _tabController.animateTo(index);
                    });
                  },
                ),
                IndexedStack(
                  index: _selectedIndex,
                  children: [
                    Visibility(
                      visible: _selectedIndex == 0,
                      maintainState: true,
                      child: EntityDisplay<AMAlbum>(
                        scrollable: false,
                        request: AMSearchAlbumsRequest.forArtist(artist),
                        detailWidgetBuilder: (album) =>
                            AppleMusicAlbumView(album: album),
                      ),
                    ),
                    Visibility(
                      visible: _selectedIndex == 1,
                      maintainState: true,
                      child: EntityDisplay<AMSong>(
                        scrollable: false,
                        request: AMSearchSongsRequest.forArtist(artist),
                        scrobbleableEntity: (track) async => track,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
