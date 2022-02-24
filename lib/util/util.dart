import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart';

const isDebug = kDebugMode;
const isWeb = kIsWeb;
final isDesktop = !isWeb && Platform.isMacOS;
final isMobile = !isWeb && !isDesktop;
var isScreenshotTest = false;

const authCallbackUrl = isWeb
    ? isDebug
        ? 'http://localhost:52486/auth.html'
        : 'https://web.finale.app/auth.html'
    : 'finale://web.finale.app/auth';

const spotifyGreen = Color.fromRGBO(30, 215, 96, 1);
const appleMusicPink = Color.fromRGBO(252, 90, 113, 1);
const scrobbleIcon = Icons.playlist_add;

String pluralize(num howMany, [String noun = 'scrobble']) =>
    Intl.plural(howMany,
        one: '$howMany $noun',
        other: '${numberFormat.format(howMany)} ${noun}s');

final numberFormat = NumberFormat();
final dateFormat = DateFormat('d MMM');
final dateFormatWithYear = DateFormat('d MMM yyyy');
final monthFormat = DateFormat('MMMM yyyy');
final timeFormat = DateFormat.jm();
final timeFormatWithSeconds = DateFormat.jms();
final dateTimeFormat = DateFormat('d MMM').add_jm();
final dateTimeFormatWithSeconds = DateFormat('d MMM').add_jms();
final dateTimeFormatWithYear = DateFormat('d MMM yyyy').add_jm();

String formatDuration(Duration duration) {
  final components = <String>[];

  if (duration.inDays > 0) {
    components.add(pluralize(duration.inDays, 'day'));
    duration -= Duration(days: duration.inDays);
  }

  if (duration.inHours > 0) {
    components.add(pluralize(duration.inHours, 'hour'));
    duration -= Duration(hours: duration.inHours);
  }

  if (duration.inMinutes > 0) {
    components.add(pluralize(duration.inMinutes, 'minute'));
  }

  return components.join(', ');
}

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
