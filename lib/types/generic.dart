import 'package:intl/intl.dart';

abstract class GenericImage {
  String get url;
}

abstract class Displayable {
  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  List<GenericImage> get images => null;
}

abstract class BasicTrack extends Displayable {
  String get name;

  List<GenericImage> get images;

  String get artist;

  String get album;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artist;
}

abstract class BasicScrobbledTrack extends BasicTrack {
  DateTime get date;

  @override
  String get displayTrailing {
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

abstract class BasicAlbum extends Displayable {
  String get name;

  BasicArtist get artist;

  List<GenericImage> get images;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artist.name;
}

abstract class BasicScrobbledAlbum extends BasicAlbum {
  String get playCount;

  @override
  String get displayTrailing => '$playCount scrobbles';
}

abstract class BasicArtist extends Displayable {
  String get name;

  List<GenericImage> get images;

  @override
  String get displayTitle => name;
}

abstract class BasicScrobbledArtist extends BasicArtist {
  String get playCount;

  @override
  String get displayTrailing => '$playCount scrobbles';
}
