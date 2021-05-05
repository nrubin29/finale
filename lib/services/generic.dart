import 'dart:async';

import 'package:finale/services/lastfm/lastfm.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat();

String formatNumber(int number) => _numberFormat.format(number);

enum DisplayableType { track, album, artist, user }

abstract class Displayable {
  DisplayableType get type;

  String get url;

  String get displayTitle;

  String get displaySubtitle => null;

  String get displayTrailing => null;

  String imageId;

  Future<String> get imageIdFuture => null;
}

abstract class BasicTrack extends Displayable {
  String get name;

  String get artist;

  String get album;

  @override
  DisplayableType get type => DisplayableType.track;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artist;
}

class BasicConcreteTrack extends BasicTrack {
  String name;
  String artist;
  String album;
  String url;
  int duration;

  BasicConcreteTrack(this.name, this.artist, this.album,
      {this.url, this.duration});

  @override
  String toString() =>
      'BasicConcreteTrack(name=$name, artist=$artist, album=$album)';
}

abstract class BasicScrobbleableTrack extends BasicTrack {
  int get duration;
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
}

abstract class FullAlbum extends BasicAlbum {
  List<BasicScrobbleableTrack> get tracks;

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
