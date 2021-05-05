import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/cache.dart';
import 'package:finale/services/generic.dart';
import 'package:flutter/material.dart';

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
    @required this.displayable,
    this.quality = ImageQuality.high,
    this.fit,
    this.width,
    this.isCircular = false,
  });

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
        errorWidget: (context, url, error) => placeholder,
        fit: fit,
        width: width);

    return isCircular ? _buildCircularImage(context, image) : image;
  }

  @override
  Widget build(BuildContext context) {
    if (displayable.imageId != null) {
      return _buildImage(context, displayable.imageId);
    } else if (displayable.url == null) {
      return _buildImage(context, null);
    }

    return FutureBuilder<String>(
        future: ImageIdCache().get(displayable.url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImage(context, null);
          }

          final cachedImageId = snapshot.data;

          if (cachedImageId != null) {
            displayable.imageId = cachedImageId;
            return _buildImage(context, cachedImageId);
          }

          return FutureBuilder<String>(
            future: displayable.imageIdFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // TODO: Move this logic out of the Widget builder.
                ImageIdCache().insert(displayable.url, snapshot.data);
                displayable.imageId = snapshot.data;
              }

              return _buildImage(context, snapshot.data);
            },
          );
        });
  }
}
