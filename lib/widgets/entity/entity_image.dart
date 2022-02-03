import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';

enum PlaceholderBehavior { image, active, none }

class EntityImage extends StatefulWidget {
  static var censorImages = false;

  final Entity entity;
  final ImageQuality quality;
  final BoxFit fit;
  final double? width;
  final bool isCircular;
  final PlaceholderBehavior placeholderBehavior;

  const EntityImage({
    required this.entity,
    this.quality = ImageQuality.high,
    this.fit = BoxFit.contain,
    this.width,
    this.isCircular = false,
    this.placeholderBehavior = PlaceholderBehavior.image,
  });

  @override
  State<StatefulWidget> createState() => _EntityImageState();
}

class _EntityImageState extends State<EntityImage> {
  ImageId? _imageId;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchImageId();
  }

  PlaceholderBehavior get _placeholderBehavior => isScreenshotTest
      ? PlaceholderBehavior.active
      : widget.placeholderBehavior;

  Future<void> _fetchImageId() async {
    setState(() {
      _loading = true;
    });

    await widget.entity.tryCacheImageId(widget.quality);

    if (mounted) {
      setState(() {
        _imageId = widget.entity.cachedImageId;
        _loading = false;
      });
    }
  }

  @override
  void didUpdateWidget(EntityImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.entity != oldWidget.entity) {
      _imageId = null;
      _fetchImageId();
    }
  }

  Widget _buildCircularImage(Widget image) => SizedBox(
        width: widget.width,
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: image,
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_loading && _placeholderBehavior == PlaceholderBehavior.active) {
      return const CircularProgressIndicator();
    }

    final placeholder = _placeholderBehavior == PlaceholderBehavior.none
        ? const SizedBox()
        : _Placeholder(widget.entity, widget.quality, widget.width);

    if (_imageId == null) {
      return widget.isCircular ? _buildCircularImage(placeholder) : placeholder;
    }

    final image = CachedNetworkImage(
      imageUrl: _imageId!.getUrl(widget.quality),
      placeholder: (_, __) => _placeholderBehavior == PlaceholderBehavior.active
          ? const CircularProgressIndicator()
          : placeholder,
      errorWidget: (_, __, ___) => placeholder,
      fit: widget.fit,
      width: widget.width,
    );

    var imageWidget = widget.isCircular ? _buildCircularImage(image) : image;

    if (isDebug) {
      if (EntityImage.censorImages && widget.entity.type != EntityType.user) {
        imageWidget = ClipRect(
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              imageWidget,
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, constraints) => BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: constraints.maxWidth / 30,
                      sigmaY: constraints.maxWidth / 30,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Stack(children: [
                          AutoSizeText(
                            'Image hidden due to copyright',
                            textAlign: TextAlign.center,
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          const AutoSizeText(
                            'Image hidden due to copyright',
                            textAlign: TextAlign.center,
                            minFontSize: 8,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

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
