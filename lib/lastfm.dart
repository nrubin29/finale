import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'env.dart';
import 'types/luser.dart';

class Lastfm {
  String _base = 'https://ws.audioscrobbler.com/2.0/';

  String _encode(String str) {
    return Uri.encodeComponent(str).replaceAll(r'%20', '+');
  }

  String _buildURL(String method,
      {Map<String, String> data = const {}, List<String> encode = const []}) {
    final allData = {
      ...data,
      ...{'api_key': apiKey, 'method': method}
    };
    var allDataKeys = allData.keys.toList();
    allDataKeys.sort();

    final hash =
        allDataKeys.map((key) => key + allData[key]).join() + apiSecret;
    final signature = md5.convert(utf8.encode(hash));
    allData['api_sig'] = signature.toString();

    allDataKeys = allData.keys.toList();
    allDataKeys.sort();
    return _base +
        '?format=json&' +
        allDataKeys
            .map((key) =>
                key +
                '=' +
                (encode.indexOf(key.replaceAll(r'\[\d+]', '')) != -1
                    ? _encode(allData[key])
                    : allData[key]))
            .join('&');
  }

  Future<LAuthenticationResponseSession> authenticate(String token) async {
    final response =
        await http.post(_buildURL('auth.getSession', data: {'token': token}));

    if (response.statusCode == 200) {
      return LAuthenticationResponseSession.fromJson(
          json.decode(response.body)['session']);
    } else {
      throw Exception('Could not authenticate.');
    }
  }

  Future<LUser> getUser(String username) async {
    final response =
        await http.get(_buildURL('user.getInfo', data: {'user': username}));

    if (response.statusCode == 200) {
      return LUser.fromJson(json.decode(response.body)['user']);
    } else {
      throw Exception('Could not get user.');
    }
  }
}
