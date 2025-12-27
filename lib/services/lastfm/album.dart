import 'package:finale/services/generic.dart';
import 'package:finale/services/image_provider.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/util/formatters.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class LTopAlbumsResponseAlbumArtist extends BasicArtist {
  @override
  final String name;

  @override
  final String? url;

  LTopAlbumsResponseAlbumArtist(this.name, this.url);

  factory LTopAlbumsResponseAlbumArtist.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumArtistFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseAlbum extends BasicScrobbledAlbum with HasPlayCount {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  @override
  final int playCount;

  @override
  final LTopAlbumsResponseAlbumArtist artist;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageProvider? imageProvider;

  LTopAlbumsResponseAlbum(
    this.name,
    this.url,
    this.playCount,
    this.artist,
    this.imageProvider,
  );

  factory LTopAlbumsResponseAlbum.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseAlbumFromJson(json);
}

@JsonSerializable()
class LTopAlbumsResponseTopAlbums
    extends LPagedResponse<LTopAlbumsResponseAlbum> {
  @JsonKey(name: 'album')
  @override
  final List<LTopAlbumsResponseAlbum> items;

  const LTopAlbumsResponseTopAlbums(super.attr, this.items);

  factory LTopAlbumsResponseTopAlbums.fromJson(Map<String, dynamic> json) =>
      _$LTopAlbumsResponseTopAlbumsFromJson(json);
}

@JsonSerializable()
class LAlbumMatch extends BasicAlbum {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(name: 'artist')
  final String artistName;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageProvider? imageProvider;

  @override
  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  LAlbumMatch(this.name, this.url, this.artistName, this.imageProvider);

  factory LAlbumMatch.fromJson(Map<String, dynamic> json) =>
      _$LAlbumMatchFromJson(json);
}

@JsonSerializable()
class LAlbumSearchResponse {
  @JsonKey(name: 'album')
  final List<LAlbumMatch> albums;

  const LAlbumSearchResponse(this.albums);

  factory LAlbumSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$LAlbumSearchResponseFromJson(json);
}

@JsonSerializable()
class LAlbumTrack extends ScrobbleableTrack {
  @override
  final String name;

  @override
  final String url;

  @JsonKey(fromJson: intParseSafe)
  @override
  final int? duration;

  // Set by LAlbum.
  @JsonKey(includeFromJson: false)
  late String album;

  final LTopAlbumsResponseAlbumArtist artist;

  @override
  String get albumName => album;

  @override
  String get artistName => artist.name;

  @override
  String? get displaySubtitle => null;

  LAlbumTrack(this.name, this.url, this.duration, this.artist);

  factory LAlbumTrack.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTrackFromJson(json);
}

@JsonSerializable()
class LAlbumTracks {
  @JsonKey(name: 'track', fromJson: parseTracks)
  final List<LAlbumTrack> tracks;

  const LAlbumTracks(this.tracks);

  factory LAlbumTracks.fromJson(Map<String, dynamic> json) =>
      _$LAlbumTracksFromJson(json);

  static List<LAlbumTrack> parseTracks(dynamic json) => json == null
      ? const []
      : json is List<dynamic>
      ? json.map((e) => LAlbumTrack.fromJson(e)).toList(growable: false)
      : List.unmodifiable([LAlbumTrack.fromJson(json)]);
}

@JsonSerializable()
class LAlbum extends FullAlbum {
  @override
  final String name;

  @JsonKey(name: 'artist')
  final String artistName;

  @override
  final String url;

  @JsonKey(name: 'image', fromJson: extractImageId)
  @override
  final ImageProvider? imageProvider;

  @JsonKey(name: 'playcount', fromJson: parseInt)
  final int playCount;

  @JsonKey(fromJson: parseInt)
  final int listeners;

  @JsonKey(name: 'userplaycount', fromJson: parseInt)
  final int userPlayCount;

  @JsonKey(name: 'tracks')
  final LAlbumTracks? tracksObject;

  @JsonKey(name: 'tags', fromJson: LTopTags.fromJsonSafe)
  final LTopTags topTags;

  final LWiki? wiki;

  @override
  BasicArtist get artist =>
      ConcreteBasicArtist(artistName, url.substring(0, url.lastIndexOf('/')));

  @override
  List<LAlbumTrack> get tracks => tracksObject?.tracks ?? const [];

  @override
  String get displayTrailing => pluralize(userPlayCount);

  LAlbum(
    this.name,
    this.artistName,
    this.url,
    this.imageProvider,
    this.playCount,
    this.userPlayCount,
    this.listeners,
    this.tracksObject,
    this.topTags,
    this.wiki,
  ) {
    if (tracksObject != null) {
      for (final track in tracksObject!.tracks) {
        track.album = name;
      }
    }
  }

  factory LAlbum.fromJson(Map<String, dynamic> json) => _$LAlbumFromJson(json);
}
