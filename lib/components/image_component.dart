import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/types/generic.dart';

enum ImageQuality { low, high }

/*
small=34s, medium=64s, large=174s, extralarge=300x300
 */
String buildImageUrl(String imageId, ImageQuality quality) {
  return 'https://lastfm.freetls.fastly.net/i/u/${quality == ImageQuality.high ? '300x300' : '64s'}/$imageId.jpg';
}

class ImageComponent extends StatelessWidget {
  final Displayable displayable;
  final ImageQuality quality;
  final BoxFit fit;

  static final Map<DisplayableType, Map<ImageQuality, AssetImage>>
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
  };

  ImageComponent(
      {Key key,
      @required this.displayable,
      this.quality = ImageQuality.high,
      this.fit})
      : super(key: key);

  Widget _buildImage(BuildContext context, String imageId) {
    AssetImage placeholder = placeholders[displayable.type][quality];

    if (imageId == null) {
      return Image(image: placeholder);
    }

    return CachedNetworkImage(
      imageUrl: buildImageUrl(imageId, quality),
      placeholder: (context, url) => Image(image: placeholder),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (displayable.imageId == null) {
      return _buildImage(context, null);
    } else if (displayable.imageId is Future) {
      return FutureBuilder<String>(
        future: displayable.imageId as Future,
        builder: (context, snapshot) {
          return _buildImage(context, snapshot.data);
        },
      );
    }

    return _buildImage(context, displayable.imageId as String);
  }
}
