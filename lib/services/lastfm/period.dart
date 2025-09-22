import 'package:collection/collection.dart';
import 'package:finale/util/formatters.dart';

sealed class Period {
  const Period();

  factory Period.deserialized(String value) {
    final apiPeriod = ApiPeriod.values.firstWhereOrNull(
      (period) => period.value == value,
    );
    if (apiPeriod != null) {
      return apiPeriod;
    }

    final parts = value.split(':');
    final start = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]));
    final end = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1]));
    return CustomPeriod(start: start, end: end);
  }

  String get display;
  String get serializedValue;
  DateTime? get start;
  String get formattedForSentence;

  @override
  String toString() => display;
}

enum ApiPeriod implements Period {
  sevenDays(value: '7day', days: 7, display: '7 days'),
  oneMonth(value: '1month', days: 30, display: '1 month'),
  threeMonths(value: '3month', days: 91, display: '3 months'),
  sixMonths(value: '6month', days: 182, display: '6 months'),
  twelveMonths(value: '12month', days: 365, display: '12 months'),
  overall(value: 'overall', display: 'Overall');

  final String value;
  final int? days;

  @override
  final String display;

  const ApiPeriod({required this.value, this.days, required this.display});

  @override
  String get serializedValue => value;

  /// The start date of this period relative to now.
  @override
  DateTime? get start =>
      this == overall ? null : DateTime.now().subtract(Duration(days: days!));

  @override
  String get formattedForSentence => switch (this) {
    sevenDays => 'in the last 7 days',
    oneMonth => 'in the last month',
    threeMonths => 'in the last 3 months',
    sixMonths => 'in the last 6 months',
    twelveMonths => 'in the last 12 months',
    overall => 'overall',
  };
}

class CustomPeriod extends Period {
  @override
  final String display;

  @override
  final DateTime start;

  final DateTime end;

  CustomPeriod({required this.start, required this.end})
    : display = formatDateRange(start, end);

  @override
  String get serializedValue =>
      '${start.millisecondsSinceEpoch}:${end.millisecondsSinceEpoch}';

  @override
  bool operator ==(Object other) =>
      other is CustomPeriod && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String get formattedForSentence =>
      'between ${formatDateRange(start, end, separator: 'and')}';
}
