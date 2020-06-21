import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dcache/dcache.dart';
import 'package:finale/types/generic.dart';
import 'package:flutter/material.dart';

enum ImageQuality { low, high }

/*
small=34s, medium=64s, large=174s, extralarge=300x300
 */
String buildImageUrl(String imageId, ImageQuality quality) {
  return 'https://lastfm.freetls.fastly.net/i/u/${quality == ImageQuality.high ? '300x300' : '64s'}/$imageId.jpg';
}

/// A cache for imageId Futures.
/// TODO: Use sqflite instead of an in-memory cache - CachedNetworkImage uses it
final _cache = SimpleCache<String, String>(storage: SimpleStorage(size: 100));

class ImageComponent extends StatelessWidget {
  final Displayable displayable;
  final ImageQuality quality;
  final BoxFit fit;
  final double width;
  final bool isCircular;

  static const Map<DisplayableType, Map<ImageQuality, AssetImage>>
      placeholders = {
    DisplayableType.track: {
      ImageQuality.low: AssetImage('assets/images/default_track_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_track.jpg'),
    },
    DisplayableType.album: {
      ImageQuality.low: AssetImage('assets/images/default_album_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_album.jpg'),
    },
    DisplayableType.artist: {
      ImageQuality.low: AssetImage('assets/images/default_artist_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_artist.jpg'),
    },
    DisplayableType.user: {
      ImageQuality.low: AssetImage('assets/images/default_user_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_user.jpg'),
    },
  };

  ImageComponent({
    Key key,
    @required this.displayable,
    this.quality = ImageQuality.high,
    this.fit,
    this.width,
    this.isCircular = false,
  }) : super(key: key);

  Widget _buildCircularImage(BuildContext context, Widget image) => Container(
      width: width,
      child: Material(
          shape: CircleBorder(), clipBehavior: Clip.hardEdge, child: image));

  Widget _buildImage(BuildContext context, String imageId) {
    Image placeholder = Image(
        image: placeholders[displayable.type][quality], width: width, fit: fit);

    if (imageId == null) {
      return isCircular
          ? _buildCircularImage(context, placeholder)
          : placeholder;
    }

    final image = CachedNetworkImage(
        imageUrl: buildImageUrl(imageId, quality),
        placeholder: (context, url) => placeholder,
        fit: fit,
        width: width);

    return isCircular ? _buildCircularImage(context, image) : image;
  }

  @override
  Widget build(BuildContext context) {
    if (displayable.imageId == null) {
      return _buildImage(context, null);
    } else if (displayable.imageId is String) {
      return _buildImage(context, displayable.imageId as String);
    }

    final cachedImageId = _cache.get(displayable.url);

    if (cachedImageId != null) {
      return _buildImage(context, cachedImageId);
    }

    return FutureBuilder<String>(
      future: displayable.imageId as Future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // TODO: Move this logic out of the Widget builder.
          _cache.set(displayable.url, snapshot.data);
        }

        return _buildImage(context, snapshot.data);
      },
    );
  }
}
