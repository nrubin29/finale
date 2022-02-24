import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/main/search_view.dart';
import 'package:finale/widgets/profile/profile_view.dart';
import 'package:finale/widgets/scrobble/scrobble_view.dart';
import 'package:finale/widgets/tools/tools_view.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  final String username;

  const MainView({required this.username});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _index = 0;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = QuickActionsManager().quickActionStream.listen((action) {
      if (action.type == QuickActionType.scrobbleOnce ||
          action.type == QuickActionType.scrobbleContinuously) {
        setState(() {
          Navigator.popUntil(context, (route) => route.isFirst);
          _index = 2;
        });
      } else if (action.type == QuickActionType.viewAlbum) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => AlbumView(album: action.value as BasicAlbum)),
        );
      } else if (action.type == QuickActionType.viewArtist) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ArtistView(artist: action.value as BasicArtist)),
        );
      } else if (action.type == QuickActionType.viewTrack) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TrackView(track: action.value as Track)),
        );
      } else if (action.type == QuickActionType.viewTab) {
        setState(() {
          Navigator.popUntil(context, (route) => route.isFirst);
          _index = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(label: 'Search', icon: Icon(Icons.search)),
          BottomNavigationBarItem(label: 'Scrobble', icon: Icon(scrobbleIcon)),
          BottomNavigationBarItem(
            label: 'Tools',
            icon: Icon(Icons.construction),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          ProfileView(username: widget.username, isTab: true),
          const SearchView(),
          const ScrobbleView(),
          const ToolsView(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
