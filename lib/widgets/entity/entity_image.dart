import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';

class EntityImage extends StatelessWidget {
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
    EntityType.playlist: {
      ImageQuality.low: AssetImage('assets/images/default_playlist_low.jpg'),
      ImageQuality.high: AssetImage('assets/images/default_playlist.jpg'),
    },
  };

  const EntityImage({
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

    Widget imageWidget =
        isCircular ? _buildCircularImage(context, image) : image;

    assert(() {
      if (censorImages && entity.type != EntityType.user) {
        imageWidget = ClipRect(
          child: Stack(children: [
            imageWidget,
            Positioned.fill(
              child: LayoutBuilder(
                builder: (_, constraints) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: constraints.maxWidth / 30,
                    sigmaY: constraints.maxWidth / 30,
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: AutoSizeText(
                        'Image hidden due to copyright',
                        textAlign: TextAlign.center,
                        minFontSize: 8,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        );
      }

      return true;
    }());

    return imageWidget;
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
