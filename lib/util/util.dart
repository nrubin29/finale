import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

const isWeb = kIsWeb;
const isMobile = !isWeb;

String get authCallbackUrl {
  var callbackUrl =
      isMobile ? 'finale://auth' : 'https://web.finale.app/auth.html';

  assert(() {
    if (isWeb) {
      callbackUrl = 'http://localhost:52486/auth.html';
    }
    return true;
  }());

  return callbackUrl;
}

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);
const scrobbleIcon = Icons.playlist_add;

SvgPicture getLastfmIcon(Color color) => SvgPicture.asset(
      'assets/images/lastfm.svg',
      color: color,
      width: 24,
    );

Widget appIcon({required double size}) => ClipRRect(
      borderRadius: BorderRadius.circular(size * .22),
      child: Image.asset('assets/images/icon.png', width: size),
    );

String formatScrobbles(int playCount) => Intl.plural(playCount,
    one: '$playCount scrobble',
    other: '${numberFormat.format(playCount)} scrobbles');

final numberFormat = NumberFormat();
final dateFormat = DateFormat('d MMM');
final dateFormatWithYear = DateFormat('d MMM yyyy');
final timeFormat = DateFormat.jms();
final dateTimeFormat = DateFormat('d MMM').add_jm();
final dateTimeFormatWithYear = DateFormat('d MMM yyyy').add_jm();

extension DateTimeUtil on DateTime {
  /// Returns a [DateTime] with the same date and time 0:00:00.
  DateTime get beginningOfDay => DateTime(year, month, day);

  /// Returns a [DateTime] with the same date and time 11:59:59 pm.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

extension PackageInfoFullVersion on PackageInfo {
  String get fullVersion => '$version+$buildNumber';
}
