import 'package:finale/services/generic.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

/// Computes the upper bound of a position in an arbitrary space.
///
/// The upper bound is the first index whose value is greater than the target
/// value as per [compare].
///
/// This implementation is best for cases where it would be expensive and
/// unnecessary to (fetch and) store the entire search space in memory. Only the
/// items that need to be compared are fetched.
Future<int> upperBound(
    int length, Future<int> Function(int index) compare) async {
  var min = 0;
  var max = length;
  while (min < max) {
    final mid = min + ((max - min) >> 1);
    final comp = await compare(mid);
    if (comp <= 0) {
      min = mid + 1;
    } else {
      max = mid;
    }
  }
  return min;
}

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
