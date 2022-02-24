import 'package:collection/collection.dart';
import 'package:finale/util/formatters.dart';

class Period {
  static const sevenDays = Period._(value: '7day', display: '7 days');
  static const oneMonth = Period._(value: '1month', display: '1 month');
  static const threeMonths = Period._(value: '3month', display: '3 months');
  static const sixMonths = Period._(value: '6month', display: '6 months');
  static const twelveMonths = Period._(value: '12month', display: '12 months');
  static const overall = Period._(value: 'overall', display: 'Overall');
  static const apiValues = [
    sevenDays,
    oneMonth,
    threeMonths,
    sixMonths,
    twelveMonths,
    overall,
  ];

  final String? value;
  final String display;
  final DateTime? start;
  final DateTime? end;

  const Period._({required this.value, required this.display})
      : start = null,
        end = null;

  Period({required this.start, required this.end})
      : value = null,
        display = formatDateRange(start!, end!);

  factory Period.deserialized(String value) {
    final apiPeriod =
        apiValues.firstWhereOrNull((period) => period.value == value);
    if (apiPeriod != null) {
      return apiPeriod;
    }

    final parts = value.split(':');
    final start = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]));
    final end = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1]));
    return Period(start: start, end: end);
  }

  bool get isCustom => start != null;

  String get serializedValue => isCustom
      ? '${start!.millisecondsSinceEpoch}:${end!.millisecondsSinceEpoch}'
      : value!;

  @override
  bool operator ==(Object other) =>
      other is Period &&
      ((isCustom &&
              other.isCustom &&
              other.start == start &&
              other.end == end) ||
          (!isCustom && !other.isCustom && other.value == value));

  @override
  int get hashCode => display.hashCode;

  @override
  String toString() => display;
}
