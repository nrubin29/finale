import 'dart:async';

import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
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

class ConcreteGenericImage extends GenericImage {
  String url;

  ConcreteGenericImage(this.url);
}

abstract class Displayable {
  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  FutureOr<List<GenericImage>> get images => null;

  Widget get detailWidget => null;
}

abstract class BasicTrack extends Displayable {
  String get name;

  FutureOr<List<GenericImage>> get images;

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
  String get url;

  Future<List<GenericImage>> get images async {
    try {
      final lastfmResponse = await http.get(this.url);
      final soup = Beautifulsoup(lastfmResponse.body);
      final rawUrl =
          soup.find_all('.header-new-gallery--link').first.attributes['href'];
      final url =
          'https://lastfm.freetls.fastly.net/i/u/^/${rawUrl.substring(rawUrl.lastIndexOf('/'))}';
      return [
        ConcreteGenericImage(url.replaceFirst('^', 'avatar300s')),
        ConcreteGenericImage(url.replaceFirst('^', 'a0'))
      ];
    } catch (e) {
      return [
        ConcreteGenericImage(
            'https://lastfm.freetls.fastly.net/i/u/300x300/2a96cbd8b46e442fc41c2b86b821562f.jpg')
      ];
    }
  }

  @override
  String get displayTitle => name;

  @override
  Widget get detailWidget => ArtistView(artist: this);
}

class ConcreteBasicArtist extends BasicArtist {
  String name;
  String url;

  ConcreteBasicArtist(this.name, [this.url]);
}

abstract class BasicScrobbledArtist extends BasicArtist {
  int get playCount;

  @override
  String get displayTrailing => '$playCount scrobbles';
}

abstract class FullArtist extends BasicArtist {}
