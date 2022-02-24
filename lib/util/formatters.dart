import 'package:intl/intl.dart';

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
