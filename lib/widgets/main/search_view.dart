import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/services/spotify/track.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_album_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_artist_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog.dart';
import 'package:finale/widgets/entity/spotify/spotify_playlist_view.dart';
import 'package:finale/widgets/scrobble/batch_scrobble_view.dart';
import 'package:finale/widgets/scrobble/scrobble_view.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:social_media_buttons/social_media_icons.dart';

extension SearchEngineIcon on SearchEngine {
  Widget getIcon(Color color) {
    switch (this) {
      case SearchEngine.lastfm:
        return getLastfmIcon(color);
      case SearchEngine.spotify:
        return Icon(SocialMediaIcons.spotify, color: color);
    }
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
  }

  PagedRequest<BasicArtist> searchArtists(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchArtistsRequest(query);
      case SearchEngine.spotify:
        return SSearchArtistsRequest(query);
    }
  }

  PagedRequest<BasicAlbum> searchAlbums(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchAlbumsRequest(query);
      case SearchEngine.spotify:
        return SSearchAlbumsRequest(query);
    }
  }

  PagedRequest<BasicPlaylist> searchPlaylists(String query) {
    assert(this == SearchEngine.spotify);
    return SSearchPlaylistsRequest(query);
  }
}

class SearchQuery {
  final SearchEngine searchEngine;
  final String text;

  const SearchQuery._(this.searchEngine, this.text);

  const SearchQuery.empty(SearchEngine searchEngine) : this._(searchEngine, '');

  SearchQuery copyWith({SearchEngine? searchEngine, String? text}) =>
      SearchQuery._(searchEngine ?? this.searchEngine, text ?? this.text);

  @override
  String toString() => 'SearchQuery(searchEngine=$searchEngine, text=$text)';
}

class SearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  static const debounceDuration =
      Duration(milliseconds: Duration.millisecondsPerSecond ~/ 2);

  final _textController = TextEditingController();
  late TabController _tabController;
  final _query = ReplaySubject<SearchQuery>(maxSize: 2)
    ..add(SearchQuery.empty(Preferences().searchEngine));
  var _spotifyEnabled = true;

  @override
  void initState() {
    super.initState();
    _setSpotifyEnabled();
    _tabController = TabController(
        length: _searchEngine == SearchEngine.spotify ? 4 : 3, vsync: this);
    Preferences().spotifyEnabledChange.listen((_) {
      _setSpotifyEnabled();
      _updateTabController();
    });

    _query.listen((_) async {
      Preferences().searchEngine = _searchEngine;
    });
  }

  void _updateTabController([SearchEngine? searchEngine]) {
    _tabController.dispose();

    var length =
        (searchEngine ?? _searchEngine) == SearchEngine.spotify ? 4 : 3;
    setState(() {
      _tabController = TabController(
          initialIndex: min(_tabController.index, length - 1),
          length: length,
          vsync: this);
    });
  }

  void _setSpotifyEnabled() {
    _spotifyEnabled = Preferences().spotifyEnabled;

    if (_searchEngine == SearchEngine.spotify &&
        (!_spotifyEnabled || !Preferences().isSpotifyLoggedIn)) {
      setState(() {
        _query.add(_currentQuery.copyWith(searchEngine: SearchEngine.lastfm));
      });
    }
  }

  SearchQuery get _currentQuery => _query.values.last;

  SearchEngine get _searchEngine => _currentQuery.searchEngine;

  /// Determine whether or not we should debounce before the given query.
  ///
  /// We want to debounce if the text changes, but we want search engine changes
  /// to be immediate.
  bool _shouldDebounce(SearchQuery query) =>
      query.text != _query.values.first.text;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor:
              _searchEngine == SearchEngine.lastfm ? null : spotifyGreen,
          titleSpacing: _spotifyEnabled ? 0 : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _spotifyEnabled
                  ? Row(children: [
                      ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<SearchEngine>(
                          iconEnabledColor: Colors.white,
                          isDense: true,
                          underline: SizedBox(),
                          items: SearchEngine.values
                              .map((searchEngine) => DropdownMenuItem(
                                  value: searchEngine,
                                  child: searchEngine.getIcon(
                                      _searchEngine == SearchEngine.lastfm
                                          ? Colors.red
                                          : spotifyGreen)))
                              .toList(growable: false),
                          selectedItemBuilder: (context) => SearchEngine.values
                              .map((searchEngine) =>
                                  searchEngine.getIcon(Colors.white))
                              .toList(growable: false),
                          value: _searchEngine,
                          onChanged: (choice) async {
                            if (choice == _searchEngine) {
                              return;
                            }

                            var updateSearchEngine = true;

                            if (choice == SearchEngine.spotify &&
                                !Preferences().hasSpotifyAuthData) {
                              updateSearchEngine = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => SpotifyDialog()) ??
                                  false;
                            }

                            if (updateSearchEngine) {
                              _updateTabController(choice);
                              setState(() {
                                _query.add(_currentQuery.copyWith(
                                    searchEngine: choice));
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                    ])
                  : Container(),
              Expanded(
                  child: TextField(
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
              )),
            ],
          ),
          actions: [
            Visibility(
                visible: _textController.text != '',
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
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.audiotrack)),
              Tab(icon: Icon(Icons.people)),
              Tab(icon: Icon(Icons.album)),
              if (_searchEngine == SearchEngine.spotify)
                Tab(icon: Icon(Icons.queue_music)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _currentQuery.text != ''
              ? [
                  EntityDisplay<Track>(
                      secondaryAction: (item) async {
                        Track track;

                        if (item is STrack) {
                          track = item;
                        } else {
                          track = await Lastfm.getTrack(item);
                        }

                        await showBarModalBottomSheet(
                            context: context,
                            duration: Duration(milliseconds: 200),
                            builder: (context) => ScrobbleView(
                                  track: track,
                                  isModal: true,
                                ));
                      },
                      requestStream: _query
                          .debounceWhere(_shouldDebounce, debounceDuration)
                          .map((query) =>
                              query.searchEngine.searchTracks(query.text)),
                      detailWidgetBuilder: _searchEngine == SearchEngine.spotify
                          ? null
                          : (track) => TrackView(track: track)),
                  EntityDisplay<BasicArtist>(
                      displayType: DisplayType.grid,
                      requestStream: _query
                          .debounceWhere(_shouldDebounce, debounceDuration)
                          .map((query) =>
                              query.searchEngine.searchArtists(query.text)),
                      detailWidgetBuilder: (artist) =>
                          _searchEngine == SearchEngine.spotify
                              ? SpotifyArtistView(artist: artist)
                              : ArtistView(artist: artist)),
                  EntityDisplay<BasicAlbum>(
                      secondaryAction: (item) async {
                        FullAlbum album;

                        if (item is SAlbumSimple) {
                          album = await Spotify.getFullAlbum(item);
                        } else {
                          album = await Lastfm.getAlbum(item);
                        }

                        if (album.tracks.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('This album doesn\'t have any tracks')));
                          return;
                        } else if (!album.canScrobble) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Can\'t scrobble album because track '
                                      'duration data is missing')));
                          return;
                        }

                        await showBarModalBottomSheet(
                            context: context,
                            duration: Duration(milliseconds: 200),
                            builder: (context) =>
                                BatchScrobbleView(entity: album));
                      },
                      displayType: DisplayType.grid,
                      requestStream: _query
                          .debounceWhere(_shouldDebounce, debounceDuration)
                          .map((query) =>
                              query.searchEngine.searchAlbums(query.text)),
                      detailWidgetBuilder: (album) =>
                          _searchEngine == SearchEngine.spotify
                              ? SpotifyAlbumView(album: album as SAlbumSimple)
                              : AlbumView(album: album)),
                  if (_searchEngine == SearchEngine.spotify)
                    EntityDisplay<BasicPlaylist>(
                        secondaryAction: (item) async {
                          var playlist = await Spotify.getFullPlaylist(
                              item as SPlaylistSimple);

                          if (playlist.tracks.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('This playlist doesn\'t have any '
                                    'tracks')));
                            return;
                          } else if (!playlist.canScrobble) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Can\'t scrobble playlist because '
                                        'track duration data is missing')));
                            return;
                          }

                          await showBarModalBottomSheet(
                              context: context,
                              duration: Duration(milliseconds: 200),
                              builder: (context) =>
                                  BatchScrobbleView(entity: playlist));
                        },
                        displayType: DisplayType.grid,
                        requestStream: _query
                            .debounceWhere(_shouldDebounce, debounceDuration)
                            .map((query) =>
                                query.searchEngine.searchPlaylists(query.text)),
                        detailWidgetBuilder: (playlist) => SpotifyPlaylistView(
                            playlist: playlist as SPlaylistSimple)),
                ]
              : [
                  Container(),
                  Container(),
                  Container(),
                  if (_searchEngine == SearchEngine.spotify) Container(),
                ],
        ),
      );

  @override
  void dispose() {
    _textController.dispose();
    _query.close();
    super.dispose();
  }
}

extension _DebounceWhere<T> on Stream<T> {
  Stream<T> debounceWhere(bool Function(T) test, Duration duration) {
    return debounce(
        (e) => test(e) ? TimerStream(true, duration) : Stream.value(true));
  }
}
