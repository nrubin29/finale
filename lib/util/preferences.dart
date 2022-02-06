import 'dart:async';

import 'package:finale/util/period.dart';
import 'package:finale/util/theme.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchEngine { lastfm, spotify }

class Preferences {
  static Preferences? _instance;

  factory Preferences() {
    _instance ??= Preferences._();
    return _instance!;
  }

  Preferences._();

  late SharedPreferences _preferences;

  Future<void> setup() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Period get period {
    if (!_preferences.containsKey('periodValue')) {
      _preferences.setString('periodValue', Period.sevenDays.serializedValue);
      _periodChange.add(Period.sevenDays);
    }

    return Period.deserialized(_preferences.getString('periodValue')!);
  }

  set period(Period value) {
    _preferences.setString('periodValue', value.serializedValue);
    _periodChange.add(value);
  }

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _periodChange = PublishSubject<Period>();

  Stream<Period> get periodChange => _periodChange;

  String? get name => _preferences.getString('name');

  set name(String? value) {
    if (value != null) {
      _preferences.setString('name', value);
    } else {
      _preferences.remove('name');
    }
  }

  String? get key => _preferences.getString('key');

  set key(String? value) {
    if (value != null) {
      _preferences.setString('key', value);
    } else {
      _preferences.remove('key');
    }
  }

  String? get spotifyAccessToken =>
      _preferences.getString('spotifyAccessToken');

  set spotifyAccessToken(String? value) {
    if (value != null) {
      _preferences.setString('spotifyAccessToken', value);
    } else {
      _preferences.remove('spotifyAccessToken');
    }
  }

  String? get spotifyRefreshToken =>
      _preferences.getString('spotifyRefreshToken');

  set spotifyRefreshToken(String? value) {
    if (value != null) {
      _preferences.setString('spotifyRefreshToken', value);
    } else {
      _preferences.remove('spotifyRefreshToken');
    }
  }

  DateTime? get spotifyExpiration =>
      _preferences.containsKey('spotifyExpiration')
          ? DateTime.fromMillisecondsSinceEpoch(
              _preferences.getInt('spotifyExpiration')!)
          : null;

  set spotifyExpiration(DateTime? value) {
    if (value != null) {
      _preferences.setInt('spotifyExpiration', value.millisecondsSinceEpoch);
    } else {
      _preferences.remove('spotifyExpiration');
    }
  }

  bool get isSpotifyEnabled => _preferences.getBool('spotifyEnabled') ?? true;

  set isSpotifyEnabled(bool value) {
    _preferences.setBool('spotifyEnabled', value);
    _spotifyEnabledChange.add(null);
  }

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _spotifyEnabledChange = PublishSubject<void>();

  Stream<void> get spotifyEnabledChange => _spotifyEnabledChange;

  /// Returns true if Spotify auth data is saved.
  bool get hasSpotifyAuthData {
    return _preferences.containsKey('spotifyAccessToken') &&
        _preferences.containsKey('spotifyRefreshToken') &&
        _preferences.containsKey('spotifyExpiration');
  }

  /// Returns true if Spotify auth data is saved and the access token hasn't
  /// expired.
  bool get isSpotifyLoggedIn {
    if (!hasSpotifyAuthData) {
      return false;
    }

    return DateTime.now().isBefore(spotifyExpiration!);
  }

  void clearSpotify() {
    _preferences.remove('spotifyAccessToken');
    _preferences.remove('spotifyRefreshToken');
    _preferences.remove('spotifyExpiration');
    _spotifyEnabledChange.add(null);
  }

  String? get libreKey => _preferences.getString('libreKey');

  set libreKey(String? value) {
    if (value != null) {
      _preferences.setString('libreKey', value);
    } else {
      _preferences.remove('libreKey');
    }
  }

  bool get isLibreEnabled => _preferences.getBool('libreEnabled') ?? false;

  set isLibreEnabled(bool value) {
    _preferences.setBool('libreEnabled', value);
  }

  void clearLibre() {
    isLibreEnabled = false;
    libreKey = null;
  }

  SearchEngine get searchEngine {
    if (!_preferences.containsKey('searchEngine')) {
      _preferences.setInt('searchEngine', SearchEngine.lastfm.index);
    }

    return SearchEngine.values[_preferences.getInt('searchEngine')!];
  }

  set searchEngine(SearchEngine value) {
    _preferences.setInt('searchEngine', value.index);
  }

  bool get stripTags => _preferences.getBool('stripTags') ?? false;

  set stripTags(bool value) {
    _preferences.setBool('stripTags', value);
  }

  bool get listenMoreFrequently =>
      _preferences.getBool('listenMoreFrequently') ?? false;

  set listenMoreFrequently(bool value) {
    _preferences.setBool('listenMoreFrequently', value);
  }

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _themeColorChange = StreamController<ThemeColor>.broadcast();

  Stream<ThemeColor> get themeColorChange => _themeColorChange.stream;

  ThemeColor get themeColor =>
      ThemeColor.values[_preferences.getInt('themeColorIndex') ?? 0];

  set themeColor(ThemeColor value) {
    _preferences.setInt('themeColorIndex', value.index);
    _themeColorChange.add(value);
  }

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _appleMusicChange = StreamController<bool>.broadcast();

  Stream<bool> get appleMusicChange => _appleMusicChange.stream;

  bool get isAppleMusicEnabled =>
      _preferences.getBool('isAppleMusicEnabled') ?? true;

  set isAppleMusicEnabled(bool value) {
    _preferences.setBool('isAppleMusicEnabled', value);
    _appleMusicChange.add(value);
  }

  DateTime? get lastAppleMusicScrobble {
    final value = _preferences.getInt('lastAppleMusicScrobble');
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  set lastAppleMusicScrobble(DateTime? value) {
    assert(value != null);
    _preferences.setInt(
        'lastAppleMusicScrobble', value!.millisecondsSinceEpoch);
  }

  bool get showAlbumArtistField =>
      _preferences.getBool('showAlbumArtistField') ?? true;

  set showAlbumArtistField(bool value) {
    _preferences.setBool('showAlbumArtistField', value);
    _showAlbumArtistFieldChanged.add(value);
  }

  // This stream needs to be open for the entire lifetime of the app.
  // ignore: close_sinks
  final _showAlbumArtistFieldChanged = StreamController<bool>.broadcast();

  Stream<bool> get showAlbumArtistFieldChanged =>
      _showAlbumArtistFieldChanged.stream;

  void clear() {
    _preferences.clear();
  }
}
