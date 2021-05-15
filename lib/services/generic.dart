import 'dart:async';

import 'package:finale/http_throttle.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

final httpClient = ThrottleClient(15);

final _numberFormat = NumberFormat();

String formatNumber(int number) => _numberFormat.format(number);

abstract class PagedRequest<T extends Entity> {
  const PagedRequest();

  Future<List<T>> doRequest(int limit, int page);
}

enum EntityType { track, album, artist, user }

abstract class Entity {
  EntityType get type;

  String? get url;

  String get displayTitle;

  String? get displaySubtitle => null;

  String? get displayTrailing => null;

  FutureOr<ImageId?> get imageId => null;

  /// Used by ImageComponent. Should not be overridden.
  @JsonKey(ignore: true)
  @nonVirtual
  ImageId? cachedImageId;
}

abstract class Track extends Entity {
  String get name;

  String? get artistName;

  String? get albumName;

  @override
  EntityType get type => EntityType.track;

  @override
  String get displayTitle => name;

  @override
  String? get displaySubtitle => artistName;
}

class BasicConcreteTrack extends Track {
  @override
  final String name;

  @override
  final String? artistName;

  @override
  final String? albumName;

  @override
  final String? url;

  BasicConcreteTrack(this.name, this.artistName, this.albumName, [this.url]);

  @override
  String toString() =>
      'BasicConcreteTrack(name=$name, artist=$artistName, album=$albumName)';
}

abstract class ScrobbleableTrack extends Track {
  /// The duration of the track in seconds.
  int? get duration;
}

abstract class BasicAlbum extends Entity {
  String get name;

  BasicArtist get artist;

  @override
  EntityType get type => EntityType.album;

  @override
  String get displayTitle => name;

  @override
  String get displaySubtitle => artist.name;
}

abstract class FullAlbum extends BasicAlbum {
  List<ScrobbleableTrack> get tracks;

  bool get canScrobble =>
      tracks.every((track) => track.duration != null && track.duration! > 0);
}

abstract class BasicArtist extends Entity {
  String get name;

  @override
  FutureOr<ImageId?> get imageId async {
    if (url == null) {
      return null;
    }

    final lastfmResponse = await Lastfm.get(url!);

    try {
      final doc = parse(lastfmResponse.body);
      final rawUrl =
          doc.querySelector('.header-new-gallery--link')?.attributes['href'];

      if (rawUrl == null) {
        return null;
      }

      final imageId = rawUrl.substring(rawUrl.lastIndexOf('/') + 1);
      return ImageId.lastfm(imageId);
    } catch (e) {
      return null;
    }
  }

  @override
  EntityType get type => EntityType.artist;

  @override
  String get displayTitle => name;
}

class ConcreteBasicArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String? url;

  ConcreteBasicArtist(this.name, [this.url]);
}

abstract class FullArtist extends BasicArtist {}
