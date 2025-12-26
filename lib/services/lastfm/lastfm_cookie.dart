import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/obsessions.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/extensions.dart';
import 'package:finale/util/preferences.dart';
import 'package:http/http.dart';
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
    return isScreenshotTest ? true : (await _csrfCookie()) != null;
  }

  static Future<void> loadCookiesFromWebView() async {
    final userUri = _userUri();
    final cookies = await WebviewCookieManager().getCookies(userUri.toString());
    _cookieJar.saveFromResponse(userUri, cookies);
    Preferences.cookieExpirationDate.value = DateTime.now().add(
      const Duration(days: 365),
    );
  }

  static Future<void> clear() => _cookieJar.deleteAll();

  static Future<bool> deleteScrobble(BasicScrobbledTrack scrobble) async {
    final response = await _postWithCookie('library/delete', {
      'artist_name': scrobble.artistName,
      'track_name': scrobble.name,
      'timestamp': scrobble.date!.secondsSinceEpoch.toString(),
    });

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

  static Future<bool> setObsession(Track track, String reason) async {
    final response = await _postWithCookie('obsessions', {
      'artist_name': track.artistName,
      'name': track.name,
      'reason': reason,
    });

    return response.statusCode == 200;
  }

  static Future<bool> deleteObsession(LObsession obsession) async {
    final response = await _postWithCookie('obsessions/${obsession.id}', {
      'action': 'delete',
    });

    // This endpoint deletes the obsession and then redirects to the Obsessions
    // page so we expect a 302 (redirect) response.
    return response.statusCode == 302;
  }

  static Future<Response> _postWithCookie(
    String path,
    Map<String, String?> requestBody,
  ) async {
    final csrfCookie = (await _csrfCookie())!.value;

    final fullRequestBody = {
      'csrfmiddlewaretoken': csrfCookie,
      ...requestBody,
      'ajax': '1',
    };
    return await httpClient.post(
      _userUri(path: path),
      headers: {
        'Cookie': await _cookieHeaderValue(),
        'Referer': _userUri().toString(),
      },
      body: fullRequestBody,
    );
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
