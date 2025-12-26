import 'package:finale/services/auth.dart';
import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/preference.dart';
import 'package:finale/util/preset_date_range.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:finale/util/theme.dart';

enum SearchEngine with PreferenceEnum {
  lastfm('Last.fm'),
  spotify('Spotify'),
  appleMusic('Apple Music');

  @override
  final String displayName;

  const SearchEngine(this.displayName);
}

class Preferences {
  const Preferences._();

  static final _allPreferences = [
    period,
    name,
    key,
    spotifyAccessToken,
    spotifyRefreshToken,
    spotifyExpiration,
    spotifyEnabled,
    spotifyCheckerEnabled,
    stravaAccessToken,
    stravaRefreshToken,
    stravaExpiresAt,
    libreKey,
    libreEnabled,
    searchEngine,
    stripTags,
    listenMoreFrequently,
    themeColor,
    themeBackground,
    appleMusicEnabled,
    appleMusicBackgroundScrobblingEnabled,
    lastAppleMusicScrobble,
    showAlbumArtistField,
    inputDateTimeAsText,
    defaultDateRange,
    profileTabsOrder,
    // don't include [cookieExpirationDate] as it is handled elsewhere
  ];

  static final period = Preference<Period, String>(
    'periodValue',
    defaultValue: ApiPeriod.sevenDays,
    serialize: (value) => value.serializedValue,
    deserialize: Period.deserialized,
  );

  static final name = Preference<String?, String>('name');

  static final key = Preference<String?, String>('key');

  static Future<void> clearLastfm() async {
    name.clear();
    key.clear();
    await LastfmCookie.clear();
  }

  static final spotifyAccessToken = Preference<String?, String>(
    'spotifyAccessToken2',
  );

  static final spotifyRefreshToken = Preference<String?, String>(
    'spotifyRefreshToken2',
  );

  static final spotifyExpiration = Preference.dateTime('spotifyExpiration2');

  static final spotifyEnabled = Preference<bool, bool>(
    'spotifyEnabled',
    defaultValue: true,
  );

  static final spotifyCheckerEnabled = Preference<bool, bool>(
    'isSpotifyCheckedEnabled',
    defaultValue: false,
  );

  /// Returns true if Spotify auth data is saved.
  static bool get hasSpotifyAuthData =>
      spotifyAccessToken.hasValue &&
      spotifyRefreshToken.hasValue &&
      spotifyExpiration.hasValue;

  static void clearSpotify() {
    spotifyAccessToken.clear();
    spotifyRefreshToken.clear();
    spotifyExpiration.clear();
  }

  static final stravaAccessToken = Preference<String?, String>(
    'stravaAccessToken',
  );

  static final stravaRefreshToken = Preference<String?, String>(
    'stravaRefreshToken',
  );

  static final stravaExpiresAt = Preference.dateTime('stravaExpiresAt');

  static bool get hasStravaAuthData =>
      stravaAccessToken.hasValue &&
      stravaRefreshToken.hasValue &&
      stravaExpiresAt.hasValue;

  static TokenResponse? get stravaAuthData => hasStravaAuthData
      ? TokenResponse(
          stravaAccessToken.value!,
          stravaExpiresAt.value!,
          stravaRefreshToken.value!,
        )
      : null;

  static set stravaAuthData(TokenResponse? tokenResponse) {
    assert(tokenResponse != null);
    stravaAccessToken.value = tokenResponse!.accessToken;
    stravaExpiresAt.value = tokenResponse.expiresAt;
    stravaRefreshToken.value = tokenResponse.refreshToken;
  }

  static void clearStravaAuthData() {
    stravaAccessToken.clear();
    stravaExpiresAt.clear();
    stravaRefreshToken.clear();
  }

  static final libreKey = Preference<String?, String>('libreKey');

  static final libreEnabled = Preference<bool, bool>(
    'libreEnabled',
    defaultValue: false,
  );

  static void clearLibre() {
    libreEnabled.value = false;
    libreKey.value = null;
  }

  static final searchEngine = Preference.forEnum<SearchEngine>(
    'searchEngine2',
    SearchEngine.values,
    defaultValue: .lastfm,
  );

  static final stripTags = Preference<bool, bool>(
    'stripTags',
    defaultValue: false,
  );

  static final listenMoreFrequently = Preference<bool, bool>(
    'listenMoreFrequently',
    defaultValue: false,
  );

  static final themeColor = Preference.forEnum<ThemeColor>(
    'themeColorIndex',
    ThemeColor.values,
    defaultValue: .red,
  );

  static final themeBackground = Preference<bool, bool>(
    'themeBackground',
    defaultValue: false,
  );

  static final appleMusicEnabled = Preference<bool, bool>(
    'isAppleMusicEnabled',
    defaultValue: true,
  );

  static final appleMusicBackgroundScrobblingEnabled = Preference<bool, bool>(
    'isAppleMusicBackgroundScrobblingEnabled',
    defaultValue: true,
  );

  static final lastAppleMusicScrobble = Preference.dateTime(
    'lastAppleMusicScrobble',
  );

  static final showAlbumArtistField = Preference<bool, bool>(
    'showAlbumArtistField',
    defaultValue: true,
  );

  static final inputDateTimeAsText = Preference<bool, bool>(
    'inputDateTimeAsText',
    defaultValue: false,
  );
  static final defaultDateRange = Preference.forEnum<PresetDateRange>(
    'defaultDateRange',
    PresetDateRange.values,
    defaultValue: .pastHour,
  );

  static final profileTabsOrder = Preference.forEnumList<ProfileTab>(
    'profileTabsOrder3',
    ProfileTab.allowedValues,
    defaultValue: ProfileTab.allowedValues,
  );

  static final cookieExpirationDate = Preference.dateTime(
    'cookieCreationDate',
    defaultValue: DateTime(2026, 10, 28),
  );

  static Future<void> clearAll() async {
    for (final preference in _allPreferences) {
      preference.clear();
    }
    await LastfmCookie.clear();
  }
}
