import 'package:finale/services/auth.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/preference.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:finale/util/theme.dart';

enum SearchEngine { lastfm, spotify, appleMusic }

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
    profileTabsOrder,
  ];

  static final period = Preference<Period, String>(
    'periodValue',
    defaultValue: Period.sevenDays,
    serialize: (value) => value.serializedValue,
    deserialize: Period.deserialized,
  );

  static final name = Preference<String?, String>('name');

  static final key = Preference<String?, String>('key');

  static void clearLastfm() {
    name.clear();
    key.clear();
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

  static TokenResponse? get stravaAuthData =>
      hasStravaAuthData
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
    defaultValue: SearchEngine.lastfm,
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
    defaultValue: ThemeColor.red,
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

  static final profileTabsOrder = Preference.forEnumList<ProfileTab>(
    'profileTabsOrder2',
    ProfileTab.values,
    defaultValue: ProfileTab.values,
  );

  static void clearAll() {
    for (final preference in _allPreferences) {
      preference.clear();
    }
  }
}
