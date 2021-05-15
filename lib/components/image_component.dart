import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/cache.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:flutter/material.dart';

class ImageComponent extends StatelessWidget {
  final Entity entity;
  final ImageQuality quality;
  final BoxFit? fit;
  final double? width;
  final bool isCircular;
  final bool showPlaceholder;

  static const placeholders = {
    EntityType.track: {
      ImageQuality.low: AssetImage('assets/images/default_track_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_track.jpg'),
    },
    EntityType.album: {
      ImageQuality.low: AssetImage('assets/images/default_album_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_album.jpg'),
    },
    EntityType.artist: {
      ImageQuality.low: AssetImage('assets/images/default_artist_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_artist.jpg'),
    },
    EntityType.user: {
      ImageQuality.low: AssetImage('assets/images/default_user_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_user.jpg'),
    },
  };

  ImageComponent({
    required this.entity,
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

  Widget _buildImage(BuildContext context, ImageId? imageId) {
    final placeholder = showPlaceholder
        ? Image(
            image: placeholders[entity.type]![quality]!, width: width, fit: fit)
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
    if (entity.cachedImageId != null) {
      return _buildImage(context, entity.cachedImageId);
    } else if (entity.imageId == null) {
      return _buildImage(context, null);
    } else if (entity.imageId is ImageId) {
      return _buildImage(context, entity.imageId as ImageId);
    } else if (entity.url == null) {
      return _buildImage(context, null);
    }

    return FutureBuilder<ImageId?>(
        future: ImageIdCache().get(entity.url!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImage(context, null);
          }

          final cachedImageId = snapshot.data;

          if (cachedImageId != null) {
            entity.cachedImageId = cachedImageId;
            return _buildImage(context, cachedImageId);
          }

          return FutureBuilder<ImageId?>(
            future: entity.imageId as Future<ImageId?>,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ImageIdCache().insert(entity.url!, snapshot.data!);
                entity.cachedImageId = snapshot.data;
              }

              return _buildImage(context, snapshot.data);
            },
          );
        });
  }
}
