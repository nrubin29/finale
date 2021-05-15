import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchEngine { lastfm, spotify }

enum Period {
  sevenDays,
  oneMonth,
  threeMonths,
  sixMonths,
  twelveMonths,
  overall
}

extension PeriodValue on Period {
  String get value {
    switch (this) {
      case Period.sevenDays:
        return '7day';
      case Period.oneMonth:
        return '1month';
      case Period.threeMonths:
        return '3month';
      case Period.sixMonths:
        return '6month';
      case Period.twelveMonths:
        return '12month';
      case Period.overall:
        return 'overall';
    }
  }
}

extension PeriodDisplay on Period {
  String get display {
    switch (this) {
      case Period.sevenDays:
        return '7 days';
      case Period.oneMonth:
        return '1 month';
      case Period.threeMonths:
        return '3 months';
      case Period.sixMonths:
        return '6 months';
      case Period.twelveMonths:
        return '12 months';
      case Period.overall:
        return 'Overall';
    }
  }
}

class Preferences {
  static Preferences? _instance;

  factory Preferences() {
    if (_instance == null) {
      _instance = Preferences._();
    }

    return _instance!;
  }

  Preferences._();

  late SharedPreferences _preferences;

  Future<void> setup() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Period get period {
    if (!_preferences.containsKey('periodIndex')) {
      _preferences.setInt('periodIndex', Period.sevenDays.index);
      _periodChange.add(Period.sevenDays);
    }

    return Period.values[_preferences.getInt('periodIndex')!];
  }

  set period(Period value) {
    _preferences.setInt('periodIndex', value.index);
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

  bool get spotifyEnabled => _preferences.getBool('spotifyEnabled') ?? true;

  set spotifyEnabled(bool spotifyEnabled) {
    _preferences.setBool('spotifyEnabled', spotifyEnabled);
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

  void clear() {
    _preferences.clear();
  }
}
