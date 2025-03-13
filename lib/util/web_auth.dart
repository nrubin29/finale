import 'package:finale/util/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

const _authScheme = 'finale-auth';
const authCallbackUrl =
    isWeb
        ? isDebug
            ? 'http://localhost:52486/auth.html'
            : 'https://web.finale.app/auth.html'
        : '$_authScheme://web.finale.app/auth';

Future<String?> showWebAuth(Uri uri, {required String queryParam}) async {
  String result;
  try {
    result = await FlutterWebAuth2.authenticate(
      url: uri.toString(),
      callbackUrlScheme: _authScheme,
    );
  } on PlatformException catch (e) {
    if (e.code == 'CANCELED') {
      return null;
    }

    rethrow;
  }

  return Uri.parse(result).queryParameters[queryParam];
}
