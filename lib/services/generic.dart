import 'dart:async';

import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/spotify/spotify.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/http_throttle.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    show DefaultCacheManager, HttpExceptionWithStatus;
import 'package:json_annotation/json_annotation.dart';

final httpClient = ThrottleClient(15);

abstract class PagedRequest<T> {
  final int limitForAllDataRequest;

  const PagedRequest({this.limitForAllDataRequest = 50});

  @protected
  Future<List<T>> doRequest(int limit, int page);

  @nonVirtual
  Future<List<T>> getData(int limit, int page) async {
    try {
      return await doRequest(limit, page);
    } on LException catch (e) {
      if (e.message == 'no such page') {
        return <T>[];
      }

      rethrow;
    }
  }

  @nonVirtual
  Future<List<T>> getAllData() async {
    final result = <T>[];
    List<T> lastResult;
    var page = 1;

    do {
      lastResult = await getData(limitForAllDataRequest, page++);
      result.addAll(lastResult);
    } while (lastResult.length >= limitForAllDataRequest);

    // [GetRecentTracksRequest] will return [limitForAllDataRequest] + 1 items
    // on the first page if the user is currently scrobbling. In all other
    // cases, we'll always get [limitForAllDataRequest] items.

    return result;
  }
}

enum EntityType {
  track('Track'),
  album('Album'),
  artist('Artist'),
  user('User'),
  playlist('Playlist'),
  other('Other');

  final String displayName;

  const EntityType(this.displayName);
}

typedef ImageIdProvider = Future<ImageId?> Function();

abstract class Entity {
  EntityType get type;

  String? get url;

  String get displayTitle;

  String? get displaySubtitle => null;

  String? get displayTrailing => null;

  ImageId? get imageId => null;

  ImageIdProvider? get imageIdProvider => null;

  Uint8List? get imageData => null;

  /// Used by ImageComponent. Should not be overridden.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @nonVirtual
  ImageId? cachedImageId;

  /// Attempts to populate [cachedImageId] and download the image.
  Future<void> tryCacheImageId([
    ImageQuality quality = ImageQuality.high,
  ]) async {
    if (cachedImageId != null || url == null) {
      return;
    }

    ImageId? result;
    var insertIntoCache = false;

    if (imageId != null) {
      result = imageId;
    } else if (imageIdProvider != null) {
      // We have to fetch the ImageId.
      try {
        // We'll try the cache first.
        result = await ImageIdCache().get(url!);

        // If it's not in the cache, we'll await the future and insert the
        // result into the cache if it's not null.
        if (result == null) {
          result = await imageIdProvider!();
          insertIntoCache = true;
        }
      } on Exception {
        // Do nothing.
      }
    }

    if (result != null) {
      if (insertIntoCache) {
        await ImageIdCache().insert(url!, result);
      }

      try {
        await DefaultCacheManager().downloadFile(result.getUrl(quality));
      } on HttpExceptionWithStatus {
        if (!isDebug || !isScreenshotTest) {
          rethrow;
        }
      }
      cachedImageId = result;
    }
  }
}

abstract class Track extends Entity {
  String get name;

  String? get artistName;

  String? get albumName;

  String? get albumArtist => null;

  @override
  EntityType get type => EntityType.track;

  @override
  String get displayTitle => name;

  @override
  String? get displaySubtitle => artistName;

  @override
  String toString() =>
      'Track(name=$name, artist=$artistName, album=$albumName, '
      'albumArtist=$albumArtist)';

  @override
  bool operator ==(Object other) =>
      other is Track &&
      other.name == name &&
      other.artistName == artistName &&
      other.albumName == albumName &&
      other.albumArtist == albumArtist;

  @override
  int get hashCode => Object.hash(name, artistName, albumName, albumArtist);
}

class BasicConcreteTrack extends Track {
  @override
  final String name;

  @override
  final String? artistName;

  @override
  final String? albumName;

  @override
  final String? albumArtist;

  @override
  final String? url;

  BasicConcreteTrack(
    this.name,
    this.artistName,
    this.albumName, [
    this.albumArtist,
    this.url,
  ]);

  @override
  String toString() =>
      'BasicConcreteTrack(name=$name, artist=$artistName, album=$albumName, '
      'albumArtist=$albumArtist)';
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

  @override
  String toString() => 'BasicAlbum(name=$name, artist=${artist.name})';

  @override
  bool operator ==(Object other) =>
      other is BasicAlbum && other.name == name && other.artist == artist;

  @override
  int get hashCode => Object.hash(name, artist);
}

class ConcreteBasicAlbum extends BasicAlbum {
  @override
  final String name;

  @override
  final BasicArtist artist;

  @override
  final String? url;

  ConcreteBasicAlbum(this.name, this.artist, [this.url]);
}

mixin HasTracks on Entity {
  List<ScrobbleableTrack> get tracks;

  bool get hasTrackDurations =>
      tracks.every((track) => track.duration != null && track.duration! > 0);
}

abstract class FullAlbum = BasicAlbum with HasTracks;

class FullConcreteAlbum extends FullAlbum {
  @override
  final String name;

  @override
  final BasicArtist artist;

  @override
  final String? url;

  @override
  List<ScrobbleableTrack> tracks;

  FullConcreteAlbum(
    this.name,
    String artistName, [
    this.tracks = const <ScrobbleableTrack>[],
    this.url,
  ]) : artist = ConcreteBasicArtist(artistName);

  @override
  String toString() => 'FullConcreteAlbum(name=$name, artist=$artist)';
}

abstract class BasicArtist extends Entity {
  String get name;

  @override
  ImageIdProvider get imageIdProvider => ImageId.scrape(
    url,
    '.header-new-gallery--link',
    spotifyFallback: SSearchArtistsRequest(name),
  );

  @override
  EntityType get type => EntityType.artist;

  @override
  String get displayTitle => name;

  @override
  String toString() => 'BasicArtist(name=$name)';

  @override
  bool operator ==(Object other) => other is BasicArtist && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class ConcreteBasicArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String? url;

  ConcreteBasicArtist(this.name, [this.url]);
}

abstract class FullArtist extends BasicArtist {}

abstract class BasicPlaylist extends Entity {
  @override
  EntityType get type => EntityType.playlist;
}

abstract class FullPlaylist = BasicPlaylist with HasTracks;
