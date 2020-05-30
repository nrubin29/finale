import 'package:intl/intl.dart';

abstract class GenericImage {
  String get url;
}

abstract class BasicTrack {
  String get name;

  List<GenericImage> get images;

  String get artist;

  String get album;
}

abstract class BasicScrobbledTrack extends BasicTrack {
  DateTime get date;

  String timeDifferenceString() {
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

    return DateFormat('dd MMM HH:mm aa').format(date);
  }
}
