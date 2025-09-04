import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';

part 'lastfm_cookie.g.dart';

class ScrobbleEditRequest {
  final String? newTitle;
  final String? newArtist;
  final String? newAlbum;

  const ScrobbleEditRequest({
    required this.newTitle,
    required this.newArtist,
    required this.newAlbum,
  });

  bool get isValid => newTitle != null || newArtist != null || newAlbum != null;

  String toSentence() => [
    if (newTitle != null) 'Edit title to $newTitle',
    if (newArtist != null) 'Edit artist to $newArtist',
    if (newAlbum != null) 'Edit album to $newAlbum',
  ].join('\n');

  Track applyToTrack(Track track) => BasicConcreteTrack(
    newTitle ?? track.name,
    newArtist ?? track.artistName,
    newAlbum ?? track.albumName,
    track.albumArtist,
    track.url,
  );
}

@JsonSerializable()
class DeleteScrobbleResult {
  final bool result;

  const DeleteScrobbleResult({required this.result});

  factory DeleteScrobbleResult.fromJson(Map<String, dynamic> json) =>
      _$DeleteScrobbleResultFromJson(json);
}

class LastfmCookie {
  static late final PersistCookieJar _cookieJar;

  static Future<void> setup() async {
    final directory =
        '${(await getApplicationSupportDirectory()).path}/cookies';
    _cookieJar = PersistCookieJar(storage: FileStorage(directory));
  }

  static Future<bool> hasCookies() async {
    return (await _csrfCookie()) != null;
  }

  static Future<void> loadCookiesFromWebView() async {
    final userUri = _userUri();
    final cookies = await WebviewCookieManager().getCookies(userUri.toString());
    _cookieJar.saveFromResponse(userUri, cookies);
  }

  static Future<void> clear() => _cookieJar.deleteAll();

  static Future<bool> deleteScrobble(BasicScrobbledTrack scrobble) async {
    final csrfCookie = (await _csrfCookie())!.value;

    final requestBody = {
      'csrfmiddlewaretoken': csrfCookie,
      'artist_name': scrobble.artistName,
      'track_name': scrobble.name,
      'timestamp': scrobble.date!.secondsSinceEpoch.toString(),
      'ajax': '1',
    };
    final response = await httpClient.post(
      _userUri(path: 'library/delete'),
      headers: {
        'Cookie': await _cookieHeaderValue(),
        'Referer': _userUri().toString(),
      },
      body: requestBody,
    );

    dynamic jsonObject;

    try {
      jsonObject = json.decode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return false;
    }

    return DeleteScrobbleResult.fromJson(jsonObject).result;
  }

  static Future<bool> editScrobble(
    BasicScrobbledTrack scrobble,
    ScrobbleEditRequest request,
  ) async {
    // We have to delete the old scrobble first or else Last.fm will ignore the
    // new scrobble (even though it claims not to).
    if (!await LastfmCookie.deleteScrobble(scrobble)) {
      return false;
    }

    final newScrobble = request.applyToTrack(scrobble);
    final result = await Lastfm.scrobble([newScrobble], [scrobble.date!]);
    return result.accepted == 1;
  }

  static Uri _userUri({String? path}) => Uri.https(
    'www.last.fm',
    'user/${Preferences.name.value!}${path == null ? '' : '/$path'}',
  );

  static Future<Cookie?> _csrfCookie() async {
    final cookies = await _cookieJar.loadForRequest(_userUri());
    return cookies.singleWhereOrNull((cookie) => cookie.name == 'csrftoken');
  }

  static Future<String> _cookieHeaderValue() async {
    final cookies = await _cookieJar.loadForRequest(_userUri());
    return cookies
        .where((cookie) => !cookie.value.contains('|'))
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ')
        .trim();
  }
}
