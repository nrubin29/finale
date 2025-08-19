import 'package:collection/collection.dart';
import 'package:finale/util/formatters.dart';

class Period {
  static const sevenDays = Period._(value: '7day', days: 7, display: '7 days');
  static const oneMonth = Period._(
    value: '1month',
    days: 30,
    display: '1 month',
  );
  static const threeMonths = Period._(
    value: '3month',
    days: 91,
    display: '3 months',
  );
  static const sixMonths = Period._(
    value: '6month',
    days: 182,
    display: '6 months',
  );
  static const twelveMonths = Period._(
    value: '12month',
    days: 365,
    display: '12 months',
  );
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
  final int? days;
  final String display;
  final DateTime? start;
  final DateTime? end;

  const Period._({required this.value, this.days, required this.display})
    : start = null,
      end = null;

  Period({required this.start, required this.end})
    : value = null,
      days = null,
      display = formatDateRange(start!, end!);

  factory Period.deserialized(String value) {
    final apiPeriod = apiValues.firstWhereOrNull(
      (period) => period.value == value,
    );
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

  /// The start date of this period.
  ///
  /// If this is an API period, the date is relative to now.
  DateTime? get relativeStart => isCustom
      ? start!
      : this == overall
      ? null
      : DateTime.now().subtract(Duration(days: days!));

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

  String get formattedForSentence => switch (this) {
    sevenDays => 'in the last 7 days',
    oneMonth => 'in the last month',
    threeMonths => 'in the last 3 months',
    sixMonths => 'in the last 6 months',
    twelveMonths => 'in the last 12 months',
    overall => 'overall',
    _ =>
      'between '
          '${formatDateRange(start!, end!, separator: 'and')}',
  };
}
