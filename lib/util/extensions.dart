import 'package:flutter/material.dart';
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

extension ListBinarySearchIndexWhere<T> on List<T> {
  int binarySearchIndexWhere<E>(E value, int Function(T, E) compare) {
    var min = 0;
    var max = length;
    while (min < max) {
      var mid = min + ((max - min) >> 1);
      var element = this[mid];
      var comp = compare(element, value);
      if (comp == 0) return mid;
      if (comp < 0) {
        min = mid + 1;
      } else {
        max = mid;
      }
    }
    return -1;
  }
}

extension DateTimeRangeCompareContains on DateTimeRange {
  int compareContains(DateTime dateTime) =>
      dateTime.isBefore(start)
          ? 1
          : dateTime.isAfter(end)
          ? -1
          : 0;
}

extension FutureErrorToNull<T> on Future<T> {
  Future<T?> errorToNull<E extends Exception>() => then<T?>(
    (value) => value,
    onError: (error) => error is E ? null : throw error,
  );
}
