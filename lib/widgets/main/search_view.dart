import 'dart:math';

import 'package:finale/services/apple_music/album.dart';
import 'package:finale/services/apple_music/apple_music.dart';
import 'package:finale/services/apple_music/artist.dart';
import 'package:finale/services/apple_music/playlist.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/spotify/album.dart';
import 'package:finale/services/spotify/playlist.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_album_view.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_artist_view.dart';
import 'package:finale/widgets/entity/apple_music/apple_music_playlist_view.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_album_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_artist_view.dart';
import 'package:finale/widgets/entity/spotify/spotify_dialog.dart';
import 'package:finale/widgets/entity/spotify/spotify_playlist_view.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_io/io.dart';

extension SearchEngineIcon on SearchEngine {
  IconData get icon {
    switch (this) {
      case SearchEngine.lastfm:
        return SocialMediaIcons.lastfm;
      case SearchEngine.spotify:
        return SocialMediaIcons.spotify;
      case SearchEngine.appleMusic:
        return SocialMediaIcons.apple;
    }
  }
}

extension SearchEngineColor on SearchEngine {
  Color? get color {
    switch (this) {
      case SearchEngine.lastfm:
        return null;
      case SearchEngine.spotify:
        return spotifyGreen;
      case SearchEngine.appleMusic:
        return appleMusicPink;
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
      case SearchEngine.appleMusic:
        return AMSearchSongsRequest(query);
    }
  }

  PagedRequest<BasicArtist> searchArtists(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchArtistsRequest(query);
      case SearchEngine.spotify:
        return SSearchArtistsRequest(query);
      case SearchEngine.appleMusic:
        return AMSearchArtistsRequest(query);
    }
  }

  PagedRequest<BasicAlbum> searchAlbums(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        return LSearchAlbumsRequest(query);
      case SearchEngine.spotify:
        return SSearchAlbumsRequest(query);
      case SearchEngine.appleMusic:
        return AMSearchAlbumsRequest(query);
    }
  }

  PagedRequest<BasicPlaylist> searchPlaylists(String query) {
    switch (this) {
      case SearchEngine.lastfm:
        throw Exception('Last.fm does not support searching for playlists.');
      case SearchEngine.spotify:
        return SSearchPlaylistsRequest(query);
      case SearchEngine.appleMusic:
        return AMSearchPlaylistsRequest(query);
    }
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
  const SearchView();

  @override
  State<StatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  static const _debounceDuration =
      Duration(milliseconds: Duration.millisecondsPerSecond ~/ 2);

  final _textController = TextEditingController();
  late TabController _tabController;
  final _query = ReplaySubject<SearchQuery>(maxSize: 2)
    ..add(SearchQuery.empty(Preferences().searchEngine));
  var _isSpotifyEnabled = true;
  var _isAppleMusicEnabled = false;

  @override
  void initState() {
    super.initState();
    _setSpotifyEnabled();
    _setAppleMusicEnabled();
    _tabController = TabController(
        length: _searchEngine == SearchEngine.lastfm ? 3 : 4, vsync: this);
    Preferences().spotifyEnabledChange.listen((_) {
      _setSpotifyEnabled();
      _updateTabController();
    });
    Preferences().appleMusicChange.listen((_) {
      _setAppleMusicEnabled();
      _updateTabController();
    });

    _query.listen((_) async {
      Preferences().searchEngine = _searchEngine;
    });
  }

  void _updateTabController([SearchEngine? searchEngine]) {
    _tabController.dispose();

    var length = (searchEngine ?? _searchEngine) == SearchEngine.lastfm ? 3 : 4;
    setState(() {
      _tabController = TabController(
          initialIndex: min(_tabController.index, length - 1),
          length: length,
          vsync: this);
    });
  }

  void _setSpotifyEnabled() {
    _isSpotifyEnabled = Preferences().isSpotifyEnabled;

    if (_searchEngine == SearchEngine.spotify &&
        (!_isSpotifyEnabled || !Preferences().hasSpotifyAuthData)) {
      setState(() {
        _query.add(_currentQuery.copyWith(searchEngine: SearchEngine.lastfm));
      });
    }
  }

  void _setAppleMusicEnabled() async {
    if (!Platform.isIOS) {
      return;
    }

    _isAppleMusicEnabled = Preferences().isAppleMusicEnabled;

    if (_searchEngine == SearchEngine.appleMusic && !_isAppleMusicEnabled) {
      setState(() {
        _query.add(_currentQuery.copyWith(searchEngine: SearchEngine.lastfm));
      });
    }
  }

  List<SearchEngine> get _enabledSearchEngines => [
        SearchEngine.lastfm,
        if (_isSpotifyEnabled) SearchEngine.spotify,
        if (_isAppleMusicEnabled) SearchEngine.appleMusic,
      ];

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
          backgroundColor: _searchEngine.color,
          titleSpacing: _enabledSearchEngines.length > 1 ? 0 : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_enabledSearchEngines.length > 1)
                Row(
                  children: [
                    ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<SearchEngine>(
                        iconEnabledColor: Colors.white,
                        isDense: true,
                        underline: const SizedBox(),
                        items: [
                          for (final searchEngine in _enabledSearchEngines)
                            DropdownMenuItem(
                              value: searchEngine,
                              child: Icon(
                                searchEngine.icon,
                                color: _searchEngine.color ??
                                    Theme.of(context).primaryColor,
                              ),
                            ),
                        ],
                        selectedItemBuilder: (_) => [
                          for (final searchEngine in _enabledSearchEngines)
                            Icon(searchEngine.icon, color: Colors.white),
                        ],
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
                          } else if (choice == SearchEngine.appleMusic) {
                            updateSearchEngine =
                                (await AppleMusic.authorize()) ==
                                    AuthorizationStatus.authorized;
                          }

                          if (updateSearchEngine) {
                            _updateTabController(choice);
                            setState(() {
                              _query.add(
                                  _currentQuery.copyWith(searchEngine: choice));
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
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
              ),
            ],
          ),
          actions: [
            Visibility(
              visible: _textController.text != '',
              maintainState: true,
              maintainAnimation: true,
              maintainSize: true,
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _textController.value = TextEditingValue.empty;
                    _query.add(_currentQuery.copyWith(text: ''));
                  });
                },
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(icon: Icon(Icons.audiotrack, color: Colors.white)),
              const Tab(icon: Icon(Icons.people, color: Colors.white)),
              const Tab(icon: Icon(Icons.album, color: Colors.white)),
              if (_searchEngine != SearchEngine.lastfm)
                const Tab(icon: Icon(Icons.queue_music, color: Colors.white)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _currentQuery.text != ''
              ? [
                  EntityDisplay<Track>(
                    scrobbleableEntity: (item) async => item is LTrackMatch
                        ? await Lastfm.getTrack(item)
                        : item,
                    requestStream: _query
                        .debounceWhere(_shouldDebounce, _debounceDuration)
                        .map((query) =>
                            query.searchEngine.searchTracks(query.text)),
                    detailWidgetBuilder: _searchEngine == SearchEngine.lastfm
                        ? (track) => TrackView(track: track)
                        : null,
                  ),
                  EntityDisplay<BasicArtist>(
                    displayType: DisplayType.grid,
                    requestStream: _query
                        .debounceWhere(_shouldDebounce, _debounceDuration)
                        .map((query) =>
                            query.searchEngine.searchArtists(query.text)),
                    detailWidgetBuilder: (artist) =>
                        _searchEngine == SearchEngine.lastfm
                            ? ArtistView(artist: artist)
                            : _searchEngine == SearchEngine.appleMusic
                                ? AppleMusicArtistView(
                                    artistId: (artist as AMArtist).id)
                                : SpotifyArtistView(artist: artist),
                  ),
                  EntityDisplay<BasicAlbum>(
                    scrobbleableEntity: (item) => item is SAlbumSimple
                        ? Spotify.getFullAlbum(item)
                        : item is AMAlbum
                            ? AppleMusic.getFullAlbum(item)
                            : Lastfm.getAlbum(item),
                    displayType: DisplayType.grid,
                    requestStream: _query
                        .debounceWhere(_shouldDebounce, _debounceDuration)
                        .map((query) =>
                            query.searchEngine.searchAlbums(query.text)),
                    detailWidgetBuilder: (album) =>
                        _searchEngine == SearchEngine.spotify
                            ? SpotifyAlbumView(album: album as SAlbumSimple)
                            : _searchEngine == SearchEngine.appleMusic
                                ? AppleMusicAlbumView(album: album as AMAlbum)
                                : AlbumView(album: album),
                  ),
                  if (_searchEngine != SearchEngine.lastfm)
                    EntityDisplay<BasicPlaylist>(
                      scrobbleableEntity: (item) => item is SPlaylistSimple
                          ? Spotify.getFullPlaylist(item)
                          : AMFullPlaylist.get(item as AMPlaylist),
                      displayType: DisplayType.grid,
                      requestStream: _query
                          .debounceWhere(_shouldDebounce, _debounceDuration)
                          .map((query) =>
                              query.searchEngine.searchPlaylists(query.text)),
                      detailWidgetBuilder: (playlist) =>
                          _searchEngine == SearchEngine.spotify
                              ? SpotifyPlaylistView(
                                  playlist: playlist as SPlaylistSimple)
                              : AppleMusicPlaylistView(
                                  playlist: playlist as AMPlaylist),
                    ),
                ]
              : [
                  const SizedBox(),
                  const SizedBox(),
                  const SizedBox(),
                  if (_searchEngine != SearchEngine.lastfm) const SizedBox(),
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
