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
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
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

extension on SearchEngine {
  IconData get icon {
    switch (this) {
      case .lastfm:
        return SocialMediaIcons.lastfm;
      case .spotify:
        return SocialMediaIcons.spotify;
      case .appleMusic:
        return SocialMediaIcons.apple;
    }
  }

  Color? get color {
    switch (this) {
      case .lastfm:
        return null;
      case .spotify:
        return spotifyGreen;
      case .appleMusic:
        return appleMusicPink;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case .lastfm:
        // This is safe because if the themeColor changes, the entire app will
        // update (see main.dart).
        return Preferences.themeColor.value.foregroundColor;
      default:
        return Colors.white;
    }
  }

  PagedRequest<Track> searchTracks(String query) {
    switch (this) {
      case .lastfm:
        return LSearchTracksRequest(query);
      case .spotify:
        return SSearchTracksRequest(query);
      case .appleMusic:
        return AMSearchSongsRequest(query);
    }
  }

  PagedRequest<BasicArtist> searchArtists(String query) {
    switch (this) {
      case .lastfm:
        return LSearchArtistsRequest(query);
      case .spotify:
        return SSearchArtistsRequest(query);
      case .appleMusic:
        return AMSearchArtistsRequest(query);
    }
  }

  PagedRequest<BasicAlbum> searchAlbums(String query) {
    switch (this) {
      case .lastfm:
        return LSearchAlbumsRequest(query);
      case .spotify:
        return SSearchAlbumsRequest(query);
      case .appleMusic:
        return AMSearchAlbumsRequest(query);
    }
  }

  PagedRequest<BasicPlaylist> searchPlaylists(String query) {
    switch (this) {
      case .lastfm:
        throw Exception('Last.fm does not support searching for playlists.');
      case .spotify:
        return SSearchPlaylistsRequest(query);
      case .appleMusic:
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
  static const _debounceDuration = Duration(
    milliseconds: Duration.millisecondsPerSecond ~/ 2,
  );

  final _textController = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  late TabController _tabController;
  final _query = ReplaySubject<SearchQuery>(maxSize: 2)
    ..add(.empty(Preferences.searchEngine.value));
  var _isSpotifyEnabled = true;
  var _isAppleMusicEnabled = false;

  @override
  void initState() {
    super.initState();
    _setSpotifyEnabled();
    _setAppleMusicEnabled();
    _tabController = TabController(
      length: _searchEngine == .lastfm ? 3 : 4,
      vsync: this,
    );
    Preferences.spotifyEnabled.changes.listen((_) {
      _setSpotifyEnabled();
      _updateTabController();
    });
    Preferences.appleMusicEnabled.changes.listen((_) {
      _setAppleMusicEnabled();
      _updateTabController();
    });

    _query.listen((_) async {
      Preferences.searchEngine.value = _searchEngine;
    });
  }

  void _updateTabController([SearchEngine? searchEngine]) {
    _tabController.dispose();

    var length = (searchEngine ?? _searchEngine) == .lastfm ? 3 : 4;
    setState(() {
      _tabController = TabController(
        initialIndex: min(_tabController.index, length - 1),
        length: length,
        vsync: this,
      );
    });
  }

  void _setSpotifyEnabled() {
    _isSpotifyEnabled = Preferences.spotifyEnabled.value;

    if (_searchEngine == .spotify &&
        (!_isSpotifyEnabled || !Preferences.hasSpotifyAuthData)) {
      setState(() {
        _query.add(_currentQuery.copyWith(searchEngine: .lastfm));
      });
    }
  }

  void _setAppleMusicEnabled() async {
    if (!isIos) {
      return;
    }

    _isAppleMusicEnabled = Preferences.appleMusicEnabled.value;

    if (_searchEngine == .appleMusic && !_isAppleMusicEnabled) {
      setState(() {
        _query.add(_currentQuery.copyWith(searchEngine: .lastfm));
      });
    }
  }

  List<SearchEngine> get _enabledSearchEngines => [
    .lastfm,
    if (_isSpotifyEnabled) .spotify,
    if (_isAppleMusicEnabled) .appleMusic,
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
      foregroundColor: _searchEngine.foregroundColor,
      backgroundColor: _searchEngine.color,
      titleSpacing: _enabledSearchEngines.length > 1 ? 0 : null,
      title: Row(
        mainAxisSize: .min,
        children: [
          if (_enabledSearchEngines.length > 1)
            Row(
              children: [
                ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<SearchEngine>(
                    iconEnabledColor: _searchEngine.foregroundColor,
                    isDense: true,
                    underline: const SizedBox(),
                    items: [
                      for (final searchEngine in _enabledSearchEngines)
                        DropdownMenuItem(
                          value: searchEngine,
                          child: Icon(
                            searchEngine.icon,
                            color:
                                _searchEngine.color ??
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                    selectedItemBuilder: (_) => [
                      for (final searchEngine in _enabledSearchEngines)
                        Icon(
                          searchEngine.icon,
                          color: _searchEngine.foregroundColor,
                        ),
                    ],
                    value: _searchEngine,
                    onChanged: (choice) async {
                      if (choice == _searchEngine) {
                        return;
                      }

                      var updateSearchEngine = true;

                      if (choice == .spotify &&
                          !Preferences.hasSpotifyAuthData) {
                        updateSearchEngine =
                            await showDialog<bool>(
                              context: context,
                              builder: (context) => SpotifyDialog(),
                            ) ??
                            false;
                      } else if (choice == .appleMusic) {
                        updateSearchEngine =
                            (await AppleMusic.authorize()) == .authorized;
                      }

                      if (updateSearchEngine) {
                        _updateTabController(choice);
                        setState(() {
                          _query.add(
                            _currentQuery.copyWith(searchEngine: choice),
                          );
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
              focusNode: _textFieldFocusNode,
              style: TextStyle(color: _searchEngine.foregroundColor),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: _searchEngine.foregroundColor),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _searchEngine.foregroundColor),
                ),
              ),
              cursorColor: _searchEngine.foregroundColor,
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
            icon: Icon(Icons.clear, color: _searchEngine.foregroundColor),
            onPressed: () {
              setState(() {
                _textController.value = .empty;
                _query.add(_currentQuery.copyWith(text: ''));
                _textFieldFocusNode.requestFocus();
              });
            },
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: _searchEngine.foregroundColor,
        labelColor: _searchEngine.foregroundColor,
        unselectedLabelColor: _searchEngine.foregroundColor,
        tabs: [
          const Tab(icon: Icon(Icons.audiotrack)),
          const Tab(icon: Icon(Icons.people)),
          const Tab(icon: Icon(Icons.album)),
          if (_searchEngine != .lastfm)
            const Tab(icon: Icon(Icons.queue_music)),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: _currentQuery.text != ''
          ? [
              EntityDisplay<Track>(
                scrobbleableEntity: (item) async =>
                    item is LTrackMatch ? await Lastfm.getTrack(item) : item,
                requestStream: _query
                    .debounceWhere(_shouldDebounce, _debounceDuration)
                    .map(
                      (query) => query.searchEngine.searchTracks(query.text),
                    ),
                detailWidgetBuilder: _searchEngine == .lastfm
                    ? (track) => TrackView(track: track)
                    : null,
              ),
              EntityDisplay<BasicArtist>(
                displayType: .grid,
                requestStream: _query
                    .debounceWhere(_shouldDebounce, _debounceDuration)
                    .map(
                      (query) => query.searchEngine.searchArtists(query.text),
                    ),
                detailWidgetBuilder: (artist) => _searchEngine == .lastfm
                    ? ArtistView(artist: artist)
                    : _searchEngine == .appleMusic
                    ? AppleMusicArtistView(artistId: (artist as AMArtist).id)
                    : SpotifyArtistView(artist: artist),
              ),
              EntityDisplay<BasicAlbum>(
                scrobbleableEntity: (item) => item is SAlbumSimple
                    ? Spotify.getFullAlbum(item)
                    : item is AMAlbum
                    ? AppleMusic.getFullAlbum(item)
                    : Lastfm.getAlbum(item),
                displayType: .grid,
                requestStream: _query
                    .debounceWhere(_shouldDebounce, _debounceDuration)
                    .map(
                      (query) => query.searchEngine.searchAlbums(query.text),
                    ),
                detailWidgetBuilder: (album) => _searchEngine == .spotify
                    ? SpotifyAlbumView(album: album as SAlbumSimple)
                    : _searchEngine == .appleMusic
                    ? AppleMusicAlbumView(album: album as AMAlbum)
                    : AlbumView(album: album),
              ),
              if (_searchEngine != .lastfm)
                EntityDisplay<BasicPlaylist>(
                  scrobbleableEntity: (item) => item is SPlaylistSimple
                      ? Spotify.getFullPlaylist(item)
                      : AMFullPlaylist.get(item as AMPlaylist),
                  displayType: .grid,
                  requestStream: _query
                      .debounceWhere(_shouldDebounce, _debounceDuration)
                      .map(
                        (query) =>
                            query.searchEngine.searchPlaylists(query.text),
                      ),
                  detailWidgetBuilder: (playlist) => _searchEngine == .spotify
                      ? SpotifyPlaylistView(
                          playlist: playlist as SPlaylistSimple,
                        )
                      : AppleMusicPlaylistView(
                          playlist: playlist as AMPlaylist,
                        ),
                ),
            ]
          : [
              const SizedBox(),
              const SizedBox(),
              const SizedBox(),
              if (_searchEngine != .lastfm) const SizedBox(),
            ],
    ),
  );

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _query.close();
    super.dispose();
  }
}

extension _DebounceWhere<T> on Stream<T> {
  Stream<T> debounceWhere(bool Function(T) test, Duration duration) {
    return debounce(
      (e) => test(e) ? TimerStream(null, duration) : .value(null),
    );
  }
}
