import 'package:package_info_plus/package_info_plus.dart';

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
