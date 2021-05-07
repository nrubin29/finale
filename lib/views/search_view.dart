import 'package:finale/components/display_component.dart';
import 'package:finale/components/spotify_dialog_component.dart';
import 'package:finale/services/generic.dart';
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

  PagedRequest<BasicArtist> searchArtists(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchArtistsRequest(query);
      case SearchEngine.spotify:
        return SSearchArtistsRequest(query);
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

class SearchQuery {
  final SearchEngine searchEngine;
  final String text;

  const SearchQuery._(this.searchEngine, this.text);
  const SearchQuery.empty() : this._(SearchEngine.lastfm, '');

  SearchQuery copyWith({SearchEngine searchEngine, String text}) =>
      SearchQuery._(searchEngine ?? this.searchEngine, text ?? this.text);

  @override
  String toString() => 'SearchQuery(searchEngine=$searchEngine, text=$text)';
}

class SearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  static const debounceDuration =
      Duration(milliseconds: Duration.millisecondsPerSecond ~/ 2);

  final _textController = TextEditingController();
  final _query = ReplaySubject<SearchQuery>(maxSize: 2)
    ..add(SearchQuery.empty());

  SearchQuery get _currentQuery => _query.values.last;

  SearchEngine get _searchEngine => _currentQuery.searchEngine;

  /// Determine whether or not we should debounce before the given query.
  ///
  /// We want to debounce if the text changes, but we want search engine changes
  /// to be immediate.
  bool _shouldDebounce(SearchQuery query) =>
      query.text != _query.values.first.text;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: _searchEngine == SearchEngine.lastfm
                  ? null
                  : Color.fromRGBO(30, 215, 96, 1),
              title: TextField(
                controller: _textController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                ),
                cursorColor: Colors.white,
                onChanged: (text) {
                  setState(() {
                    _query.add(_currentQuery.copyWith(text: text));
                  });
                },
              ),
              leading: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Center(
                  child: DropdownButton<SearchEngine>(
                    iconEnabledColor: Colors.white,
                    isDense: true,
                    underline: SizedBox(),
                    items: SearchEngine.values
                        .map((searchEngine) => DropdownMenuItem(
                            value: searchEngine,
                            child: Icon(searchEngine.icon, color: Colors.red)))
                        .toList(growable: false),
                    selectedItemBuilder: (context) => SearchEngine.values
                        .map((searchEngine) => Icon(searchEngine.icon))
                        .toList(growable: false),
                    value: _searchEngine,
                    onChanged: (choice) async {
                      if (choice == _searchEngine) {
                        return;
                      } else if (choice == SearchEngine.spotify &&
                          !(await Spotify.hasAuthData)) {
                        final loggedIn = await showDialog<bool>(
                            context: context,
                            builder: (context) => SpotifyDialogComponent());

                        if (loggedIn) {
                          setState(() {
                            _query.add(_currentQuery.copyWith(
                                searchEngine: SearchEngine.spotify));
                          });
                        }
                      } else {
                        setState(() {
                          _query.add(
                              _currentQuery.copyWith(searchEngine: choice));
                        });
                      }
                    },
                  ),
                ),
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
                          _query.add(_currentQuery.copyWith(text: ''));
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
            children: _currentQuery.text != ''
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
                            .debounceWhere(_shouldDebounce, debounceDuration)
                            .map((query) =>
                                query.searchEngine.searchTracks(query.text)),
                        detailWidgetBuilder:
                            _searchEngine == SearchEngine.spotify
                                ? null
                                : (track) => TrackView(track: track)),
                    DisplayComponent<BasicArtist>(
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceWhere(_shouldDebounce, debounceDuration)
                            .map((query) =>
                                query.searchEngine.searchArtists(query.text)),
                        detailWidgetBuilder:
                            _searchEngine == SearchEngine.spotify
                                ? null
                                : (artist) => ArtistView(artist: artist)),
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
                            .debounceWhere(_shouldDebounce, debounceDuration)
                            .map((query) =>
                                query.searchEngine.searchAlbums(query.text)),
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

extension _DebounceWhere<T> on Stream<T> {
  Stream<T> debounceWhere(bool Function(T) test, Duration duration) {
    return debounce(
        (e) => test(e) ? TimerStream(true, duration) : Stream.value(true));
  }
}
