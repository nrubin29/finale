import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';

class EntityImage extends StatefulWidget {
  final Entity entity;
  final ImageQuality quality;
  final BoxFit fit;
  final double? width;
  final bool isCircular;
  final bool showPlaceholder;

  const EntityImage({
    required this.entity,
    this.quality = ImageQuality.high,
    this.fit = BoxFit.contain,
    this.width,
    this.isCircular = false,
    this.showPlaceholder = true,
  });

  @override
  State<StatefulWidget> createState() => _EntityImageState();
}

class _EntityImageState extends State<EntityImage> {
  ImageId? _imageId;

  @override
  void initState() {
    super.initState();
    _fetchImageId();
  }

  Future<void> _fetchImageId() async {
    if (widget.entity.cachedImageId != null) {
      setState(() {
        _imageId = widget.entity.cachedImageId;
      });
      return;
    } else if (widget.entity.imageId == null) {
      return;
    } else if (widget.entity.imageId is ImageId) {
      setState(() {
        _imageId = widget.entity.imageId as ImageId;
      });
      return;
    } else if (widget.entity.url == null) {
      return;
    }

    final cachedImageId = await ImageIdCache().get(widget.entity.url!);

    if (cachedImageId != null) {
      widget.entity.cachedImageId = cachedImageId;
      setState(() {
        _imageId = cachedImageId;
      });
      return;
    }

    final futureImageId = await (widget.entity.imageId as Future<ImageId?>);

    if (futureImageId != null) {
      ImageIdCache().insert(widget.entity.url!, futureImageId);
      widget.entity.cachedImageId = futureImageId;
      setState(() {
        _imageId = futureImageId;
      });
    }
  }

  Widget _buildCircularImage(Widget image) => Container(
        width: widget.width,
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: image,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.showPlaceholder
        ? _Placeholder(widget.entity, widget.quality, widget.width)
        : Container();

    if (_imageId == null) {
      return widget.isCircular ? _buildCircularImage(placeholder) : placeholder;
    }

    final image = CachedNetworkImage(
      imageUrl: _imageId!.getUrl(widget.quality),
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
      fit: widget.fit,
      width: widget.width,
    );

    Widget imageWidget = widget.isCircular ? _buildCircularImage(image) : image;

    assert(() {
      if (censorImages && widget.entity.type != EntityType.user) {
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
}

class _Placeholder extends StatelessWidget {
  static const _iconMap = {
    EntityType.track: Icons.music_note,
    EntityType.album: Icons.album,
    EntityType.artist: Icons.people,
    EntityType.user: Icons.person,
    EntityType.playlist: Icons.queue_music,
  };

  final Entity entity;
  final ImageQuality quality;
  final double? width;

  const _Placeholder(this.entity, this.quality, this.width);

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.contain,
        child: Container(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey
              : Colors.grey.shade800,
          width: width ?? (quality == ImageQuality.high ? 470 : 64),
          height: width ?? (quality == ImageQuality.high ? 470 : 64),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              heightFactor: 0.7,
              child: FittedBox(
                child: Icon(
                  _iconMap[entity.type],
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
}
