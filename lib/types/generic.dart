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

enum ImageSize { small, medium, large, extraLarge, unknown }

ImageSize convertStringToImageSize(String text) => ImageSize.values.firstWhere(
    (size) => size.toString().split('.')[1].toLowerCase() == text,
    orElse: () => ImageSize.unknown);

abstract class GenericImage {
  String get url;

  ImageSize get size;
}

class ConcreteGenericImage extends GenericImage {
  String url;
  ImageSize size;

  ConcreteGenericImage(this.url, this.size);
}

enum DisplayableType { track, album, artist }

abstract class Displayable {
  DisplayableType get type;

  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  // TODO: Whenever [images] is a [FutureOr], the result of the [Future] should
  //  be cached like [ArtistImageCache]
  FutureOr<List<GenericImage>> get images => null;

  Widget get detailWidget => null;
}

abstract class BasicTrack extends Displayable {
  String get name;

  FutureOr<List<GenericImage>> get images;

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

  List<GenericImage> get images;

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
  static final _cache = SimpleCache<String, List<GenericImage>>(
      storage: SimpleStorage(size: 100));

  static List<GenericImage> get(String url) => _cache.get(url);

  static void set(String url, List<GenericImage> value) =>
      _cache.set(url, value);
}

abstract class BasicArtist extends Displayable {
  String get name;

  String get url;

  Future<List<GenericImage>> get images async {
    List<GenericImage> cachedImages = ArtistImageCache.get(url);

    if (cachedImages != null) {
      return cachedImages;
    }

    final lastfmResponse = await http.get(this.url);

    try {
      final soup = Beautifulsoup(lastfmResponse.body);
      final rawUrl =
          soup.find_all('.header-new-gallery--link').first.attributes['href'];
      final imageUrl =
          'https://lastfm.freetls.fastly.net/i/u/^/${rawUrl.substring(rawUrl.lastIndexOf('/'))}.jpg';

      final images = [
        ConcreteGenericImage(
            imageUrl.replaceFirst('^', '34s'), ImageSize.small),
        ConcreteGenericImage(
            imageUrl.replaceFirst('^', '64s'), ImageSize.medium),
        ConcreteGenericImage(
            imageUrl.replaceFirst('^', '174s'), ImageSize.large),
        ConcreteGenericImage(
            imageUrl.replaceFirst('^', '300x300'), ImageSize.extraLarge),
      ];
      ArtistImageCache.set(url, images);
      return images;
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
