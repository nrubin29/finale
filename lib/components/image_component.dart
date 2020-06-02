import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/types/generic.dart';

enum ImageQuality { low, high }

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

  Widget _buildImage(BuildContext context, List<GenericImage> images) {
    AssetImage placeholder = placeholders[displayable.type][quality];

    if (images == null || images.isEmpty) {
      return Image(image: placeholder);
    }

    return CachedNetworkImage(
      imageUrl: images
          .firstWhere((image) =>
              image.size ==
              (quality == ImageQuality.high
                  ? ImageSize.extraLarge
                  : ImageSize.medium))
          .url,
      placeholder: (context, url) => Image(image: placeholder),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (displayable.images == null) {
      return _buildImage(context, null);
    } else if (displayable.images is Future) {
      return FutureBuilder<List<GenericImage>>(
        future: displayable.images as Future,
        builder: (context, snapshot) {
          return _buildImage(context, snapshot.data);
        },
      );
    }

    return _buildImage(context, displayable.images as List<GenericImage>);
  }
}
