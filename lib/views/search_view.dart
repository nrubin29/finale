import 'package:finale/components/display_component.dart';
import 'package:finale/components/spotify_dialog_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/views/album_view.dart';
import 'package:finale/views/artist_view.dart';
import 'package:finale/views/scrobble_album_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:finale/views/track_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:social_media_buttons/social_media_icons.dart';

enum SearchEngine { lastfm, spotify }

extension SearchEngineIcon on SearchEngine {
  IconData get icon {
    switch (this) {
      case SearchEngine.lastfm:
        return Icons.music_note;
      case SearchEngine.spotify:
        return SocialMediaIcons.spotify;
    }

    return Icons.error;
  }
}

extension SearchEngineQuery on SearchEngine {
  PagedRequest<Track> searchTracks(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchTracksRequest(query);
      case SearchEngine.spotify:
        return SSearchTracksRequest(query);
    }

    throw Exception('Unknown search engine $this');
  }

  PagedRequest<BasicAlbum> searchAlbums(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchAlbumsRequest(query);
      case SearchEngine.spotify:
        return SSearchAlbumsRequest(query);
    }

    throw Exception('Unknown search engine $this');
  }
}

class SearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _textController = TextEditingController();
  var _searchEngine = SearchEngine.lastfm;
  final _query = BehaviorSubject<String>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              title: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white)),
                onChanged: (text) {
                  setState(() {
                    _query.add(text);
                  });
                },
              ),
              leading: DropdownButton<SearchEngine>(
                items: SearchEngine.values
                    .map((searchEngine) => DropdownMenuItem(
                        value: searchEngine,
                        child: Icon(searchEngine.icon, color: Colors.black)))
                    .toList(growable: false),
                value: _searchEngine,
                onChanged: (choice) async {
                  if (choice == _searchEngine) {
                    return;
                  } else if (choice == SearchEngine.spotify &&
                      !(await Spotify.isLoggedIn)) {
                    final loggedIn = await showDialog<bool>(
                        context: context,
                        builder: (context) => SpotifyDialogComponent());

                    if (loggedIn) {
                      setState(() {
                        _searchEngine = SearchEngine.spotify;
                      });
                    }
                  } else {
                    setState(() {
                      _searchEngine = choice;
                    });
                  }
                },
              ),
              actions: [
                Visibility(
                    visible:
                        _textController != null && _textController.text != '',
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.value = TextEditingValue.empty;
                          _query.add('');
                        });
                      },
                    ))
              ],
              bottom: TabBar(tabs: [
                Tab(icon: Icon(Icons.audiotrack)),
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.album))
              ])),
          body: TabBarView(
            children: _query.hasValue && _query.value != ''
                ? [
                    DisplayComponent<Track>(
                        secondaryAction: (item) async {
                          Track track;

                          if (item is STrack) {
                            track = item;
                          } else {
                            track = await Lastfm.getTrack(item);
                          }

                          final result = await showBarModalBottomSheet<bool>(
                              context: context,
                              duration: Duration(milliseconds: 200),
                              builder: (context) => ScrobbleView(
                                    track: track,
                                    isModal: true,
                                  ));

                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result
                                    ? 'Scrobbled successfully!'
                                    : 'An error occurred while scrobbling')));
                          }
                        },
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => _searchEngine.searchTracks(query)),
                        detailWidgetBuilder:
                            _searchEngine == SearchEngine.spotify
                                ? null
                                : (track) => TrackView(track: track)),
                    DisplayComponent<LArtistMatch>(
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => SearchArtistsRequest(query)),
                        detailWidgetBuilder: (artist) =>
                            ArtistView(artist: artist)),
                    DisplayComponent<BasicAlbum>(
                        secondaryAction: (item) async {
                          FullAlbum album;

                          if (item is SAlbumSimple) {
                            album = await Spotify.getFullAlbum(item);
                          } else {
                            album = await Lastfm.getAlbum(item);
                          }

                          if (album.tracks.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'This album doesn\'t have any tracks')));
                            return;
                          } else if (!album.canScrobble) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Can\'t scrobble album because track '
                                        'duration data is missing')));
                            return;
                          }

                          final result = await showBarModalBottomSheet<bool>(
                              context: context,
                              duration: Duration(milliseconds: 200),
                              builder: (context) =>
                                  ScrobbleAlbumView(album: album));

                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result
                                    ? 'Scrobbled successfully!'
                                    : 'An error occurred while scrobbling')));
                          }
                        },
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceTime(Duration(
                                milliseconds:
                                    Duration.millisecondsPerSecond ~/ 2))
                            .map((query) => _searchEngine.searchAlbums(query)),
                        detailWidgetBuilder:
                            _searchEngine == SearchEngine.spotify
                                ? null
                                : (album) => AlbumView(album: album)),
                  ]
                : [Container(), Container(), Container()],
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _query.close();
  }
}
