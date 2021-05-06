import 'dart:async';

import 'package:finale/services/lastfm/lastfm.dart';
import 'package:html/parser.dart' show parse;
import 'package:http_throttle/http_throttle.dart';
import 'package:intl/intl.dart';

enum RequestVerb { get, post }

final httpClient = ThrottleClient(10);

final _numberFormat = NumberFormat();

String formatNumber(int number) => _numberFormat.format(number);

abstract class PagedRequest<T extends Displayable> {
  Future<List<T>> doRequest(int limit, int page);
}

enum DisplayableType { track, album, artist, user }

abstract class Displayable {
  DisplayableType get type;

  String get url;

  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  String get imageUrl => null;

  // TODO: imageId and imageIdFuture are Last.fm-specific.

  String imageId;

  Future<String> get imageIdFuture => null;
}

abstract class Track extends Displayable {
  String get name;

  String get artistName;

  String get albumName;

  @override
  DisplayableType get type => DisplayableType.track;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artistName;
}

class BasicConcreteTrack extends Track {
  String name;
  String artistName;
  String albumName;
  String url;
  int duration;

  BasicConcreteTrack(this.name, this.artistName, this.albumName,
      {this.url, this.duration});

  @override
  String toString() =>
      'BasicConcreteTrack(name=$name, artist=$artistName, album=$albumName)';
}

abstract class ScrobbleableTrack extends Track {
  /// The duration of the track in seconds.
  int get duration;
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
}

abstract class FullAlbum extends BasicAlbum {
  List<ScrobbleableTrack> get tracks;

  bool get canScrobble =>
      tracks.every((track) => track.duration != null && track.duration > 0);
}

abstract class BasicArtist extends Displayable {
  String get name;

  @override
  Future<String> get imageIdFuture async {
    final lastfmResponse = await Lastfm.get(url);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.header-new-gallery--link').attributes['href'];
      final imageId = rawUrl.substring(rawUrl.lastIndexOf('/') + 1);
      return imageId;
    } catch (e) {
      return null;
    }
  }

  @override
  DisplayableType get type => DisplayableType.artist;

  @override
  String get displayTitle => name;
}

class ConcreteBasicArtist extends BasicArtist {
  String name;
  String url;

  ConcreteBasicArtist(this.name, [this.url]);
}

abstract class FullArtist extends BasicArtist {}
