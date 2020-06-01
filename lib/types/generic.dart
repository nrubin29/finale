import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:simplescrobble/views/album_view.dart';
import 'package:simplescrobble/views/artist_view.dart';
import 'package:simplescrobble/views/track_view.dart';

bool convertStringToBoolean(String text) => text == '1';

DateTime fromSecondsSinceEpoch(int timestamp) =>
    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

DateTime fromSecondsSinceEpochString(String text) =>
    fromSecondsSinceEpoch(int.parse(text));

final _numberFormat = NumberFormat();

String formatNumber(int number) => _numberFormat.format(number);

abstract class GenericImage {
  String get url;
}

abstract class Displayable {
  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  List<GenericImage> get images => null;

  Widget get detailWidget => null;
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

  @override
  Widget get detailWidget => TrackView(track: this);
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

abstract class FullTrack {
  String get name;

  BasicArtist get artist;

  BasicAlbum get album;
}

abstract class BasicAlbum extends Displayable {
  String get name;

  BasicArtist get artist;

  List<GenericImage> get images;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artist.name;

  @override
  Widget get detailWidget => AlbumView(album: this);
}

abstract class FullAlbum extends BasicAlbum {
  List<BasicTrack> get tracks;
}

abstract class BasicScrobbledAlbum extends BasicAlbum {
  int get playCount;

  @override
  String get displayTrailing => '$playCount scrobbles';
}

abstract class BasicArtist extends Displayable {
  String get name;

  List<GenericImage> get images;

  @override
  String get displayTitle => name;

  @override
  Widget get detailWidget => ArtistView(artist: this);
}

class ConcreteBasicArtist extends BasicArtist {
  String name;
  List<GenericImage> images;

  ConcreteBasicArtist(this.name, this.images);
}

abstract class BasicScrobbledArtist extends BasicArtist {
  int get playCount;

  @override
  String get displayTrailing => '$playCount scrobbles';
}

abstract class FullArtist extends BasicArtist {}
