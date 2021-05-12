// @dart=2.9

import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/cache.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:flutter/material.dart';

class ImageComponent extends StatelessWidget {
  final Displayable displayable;
  final ImageQuality quality;
  final BoxFit fit;
  final double width;
  final bool isCircular;
  final bool showPlaceholder;

  static const placeholders = {
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
    @required this.displayable,
    this.quality = ImageQuality.high,
    this.fit,
    this.width,
    this.isCircular = false,
    this.showPlaceholder = true,
  });

  Widget _buildCircularImage(BuildContext context, Widget image) => Container(
      width: width,
      child: Material(
          shape: CircleBorder(), clipBehavior: Clip.hardEdge, child: image));

  Widget _buildImage(BuildContext context, ImageId imageId) {
    final placeholder = showPlaceholder
        ? Image(
            image: placeholders[displayable.type][quality],
            width: width,
            fit: fit)
        : Container();

    if (imageId == null) {
      return isCircular
          ? _buildCircularImage(context, placeholder)
          : placeholder;
    }

    final image = CachedNetworkImage(
        imageUrl: imageId.getUrl(quality),
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => placeholder,
        fit: fit,
        width: width);

    return isCircular ? _buildCircularImage(context, image) : image;
  }

  @override
  Widget build(BuildContext context) {
    if (displayable.cachedImageId != null) {
      return _buildImage(context, displayable.cachedImageId);
    } else if (displayable.imageId == null) {
      return _buildImage(context, null);
    } else if (displayable.imageId is ImageId) {
      return _buildImage(context, displayable.imageId);
    }

    return FutureBuilder<String>(
        future: ImageIdCache().get(displayable.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImage(context, null);
          }

          final cachedImageId = snapshot.data;

          if (cachedImageId != null) {
            final imageId = ImageId.fromSerializedValue(cachedImageId);
            displayable.cachedImageId = imageId;
            return _buildImage(context, imageId);
          }

          return FutureBuilder<ImageId>(
            future: displayable.imageId,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ImageIdCache()
                    .insert(displayable.url, snapshot.data.serializedValue);
                displayable.cachedImageId = snapshot.data;
              }

              return _buildImage(context, snapshot.data);
            },
          );
        });
  }
}
