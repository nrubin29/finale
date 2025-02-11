import 'package:finale/services/generic.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

void pushLastfmEntityDetailView(BuildContext context, Entity entity) {
  Widget detailWidget;

  if (entity is Track) {
    detailWidget = TrackView(track: entity);
  } else if (entity is BasicAlbum) {
    detailWidget = AlbumView(album: entity);
  } else if (entity is BasicArtist) {
    detailWidget = ArtistView(artist: entity);
  } else {
    throw UnsupportedError('Unsupported entity type '
        '${entity.runtimeType}');
  }

  Navigator.push(context, MaterialPageRoute(builder: (_) => detailWidget));
}
