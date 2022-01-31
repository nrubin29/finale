import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

const isWeb = kIsWeb;
final isDesktop = !isWeb && Platform.isMacOS;
final isMobile = !isWeb && !isDesktop;
var isScreenshotTest = false;

String get authCallbackUrl {
  var callbackUrl =
      isWeb ? 'https://web.finale.app/auth.html' : 'finale://auth';

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

Widget appIcon({required double size}) => ClipRRect(
      borderRadius: BorderRadius.circular(size * .22),
      child: Image.asset('assets/images/icon.png', width: size),
    );

String formatScrobbles(int playCount, [String noun = 'scrobble']) =>
    Intl.plural(playCount,
        one: '$playCount $noun',
        other: '${numberFormat.format(playCount)} ${noun}s');

final numberFormat = NumberFormat();
final dateFormat = DateFormat('d MMM');
final dateFormatWithYear = DateFormat('d MMM yyyy');
final monthFormat = DateFormat('MMMM yyyy');
final timeFormat = DateFormat.jms();
final dateTimeFormat = DateFormat('d MMM').add_jm();
final dateTimeFormatWithYear = DateFormat('d MMM yyyy').add_jm();

String formatDateTimeDelta(DateTime? date, {bool withYear = false}) {
  if (date == null) {
    return 'scrobbling now';
  }

  final delta = DateTime.now().difference(date);

  if (delta.inDays == 0) {
    if (delta.inHours == 0) {
      return '${delta.inMinutes} min${delta.inMinutes == 1 ? '' : 's'} ago';
    }

    return '${delta.inHours} hour${delta.inHours == 1 ? '' : 's'} ago';
  }

  return (withYear ? dateTimeFormatWithYear : dateTimeFormat).format(date);
}

String formatDateRange(DateTime start, DateTime end) {
  final startFormatted = start.year == end.year
      ? dateFormat.format(start)
      : dateFormatWithYear.format(start);
  final endFormatted = dateFormatWithYear.format(end);
  return '$startFormatted - $endFormatted';
}

extension DateTimeUtil on DateTime {
  /// Returns a [DateTime] with the same date and time 0:00:00.
  DateTime get beginningOfDay => DateTime(year, month, day);

  /// Returns a [DateTime] with the same date and time 11:59:59 pm.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Returns a [DateTime] at the beginning of the [month].
  DateTime get beginningOfMonth => DateTime(year, month);

  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

extension PackageInfoFullVersion on PackageInfo {
  String get fullVersion => '$version+$buildNumber';
}

extension TitleCase on String {
  String toTitleCase() => this[0].toUpperCase() + substring(1);
}
