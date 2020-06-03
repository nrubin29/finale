import 'dart:async';

import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:dcache/dcache.dart';
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

String extractImageId(List<dynamic> /* List<Map<String, dynamic>> */ images) {
  if (images == null ||
      images.isEmpty ||
      !images.first.containsKey('#text') ||
      images.first['#text'].isEmpty) {
    return null;
  }

  final String imageUrl = images.first['#text'];
  return imageUrl.substring(imageUrl.lastIndexOf('/'));
}

enum DisplayableType { track, album, artist }

abstract class Displayable {
  DisplayableType get type;

  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  // TODO: Whenever [imageId] is a [Future], the result should be cached like
  //  [ArtistImageCache]
  FutureOr<String> get imageId => null;

  Widget get detailWidget => null;
}

abstract class BasicTrack extends Displayable {
  String get name;

  @override
  FutureOr<String> get imageId;

  String get artist;

  String get album;

  @override
  DisplayableType get type => DisplayableType.track;

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

  @override
  String get imageId;

  @override
  DisplayableType get type => DisplayableType.album;

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

// TODO: Use sqflite instead of an in-memory cache - CachedNetworkImage uses it
class ArtistImageCache {
  static final _cache =
      SimpleCache<String, String>(storage: SimpleStorage(size: 100));

  static String get(String url) => _cache.get(url);

  static void set(String url, String value) => _cache.set(url, value);
}

abstract class BasicArtist extends Displayable {
  String get name;

  String get url;

  @override
  Future<String> get imageId async {
    String cachedImageId = ArtistImageCache.get(url);

    if (cachedImageId != null) {
      return cachedImageId;
    }

    final lastfmResponse = await http.get(this.url);

    try {
      final soup = Beautifulsoup(lastfmResponse.body);
      final rawUrl =
          soup.find_all('.header-new-gallery--link').first.attributes['href'];
      final imageId = rawUrl.substring(rawUrl.lastIndexOf('/'));
      ArtistImageCache.set(url, imageId);
      return imageId;
    } catch (e) {
      ArtistImageCache.set(url, null);
      return null;
    }
  }

  @override
  DisplayableType get type => DisplayableType.artist;

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
