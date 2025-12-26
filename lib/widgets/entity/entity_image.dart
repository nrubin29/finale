import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

enum PlaceholderBehavior { image, active, none }

class EntityImage extends StatefulWidget {
  final Entity entity;
  final ImageQuality quality;
  final BoxFit fit;
  final double width;
  final bool isCircular;
  final bool shouldAnimate;
  final PlaceholderBehavior placeholderBehavior;
  final VoidCallback? onLoaded;

  EntityImage({
    required this.entity,
    this.quality = .low,
    this.fit = .contain,
    double? width,
    this.isCircular = false,
    this.shouldAnimate = true,
    this.placeholderBehavior = .image,
    this.onLoaded,
  }) : width = width ?? quality.width;

  @override
  State<StatefulWidget> createState() => _EntityImageState();
}

class _EntityImageState extends State<EntityImage> {
  ImageId? _imageId;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImageId();
  }

  PlaceholderBehavior get _placeholderBehavior =>
      isScreenshotTest ? .active : widget.placeholderBehavior;

  Future<void> _fetchImageId() async {
    if (widget.entity.imageData != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.entity.tryCacheImageId(widget.quality);

    if (mounted) {
      setState(() {
        _imageId = widget.entity.cachedImageId;
        _isLoading = false;
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
      clipBehavior: .hardEdge,
      child: image,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _placeholderBehavior == .active) {
      return const CircularProgressIndicator();
    }

    final constraints = BoxConstraints(
      maxWidth: widget.width,
      maxHeight: widget.width,
    );

    if (widget.entity.imageData != null) {
      final image = ConstrainedBox(
        constraints: constraints,
        child: Image.memory(widget.entity.imageData!, fit: widget.fit),
      );

      return widget.isCircular ? _buildCircularImage(image) : image;
    }

    final placeholder = _placeholderBehavior == .none
        ? const SizedBox()
        : _Placeholder(widget.entity, widget.quality, widget.width);

    if (_imageId == null) {
      if (!_isLoading) {
        widget.onLoaded?.call();
      }

      return widget.isCircular ? _buildCircularImage(placeholder) : placeholder;
    }

    final image = ConstrainedBox(
      constraints: constraints,
      child: OctoImage(
        image: CachedNetworkImageProvider(_imageId!.getUrl(widget.quality)),
        imageBuilder: (_, child) {
          widget.onLoaded?.call();
          return child;
        },
        placeholderBuilder: (_) => _placeholderBehavior == .active
            ? const CircularProgressIndicator()
            : placeholder,
        errorBuilder: (_, error, stackTrace) {
          FlutterError.dumpErrorToConsole(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'EntityImage',
            ),
          );
          widget.onLoaded?.call();
          return placeholder;
        },
        fadeOutDuration: widget.shouldAnimate ? null : .zero,
        fadeInDuration: widget.shouldAnimate ? null : .zero,
        fit: widget.fit,
      ),
    );

    var imageWidget = widget.isCircular ? _buildCircularImage(image) : image;

    if (isDebug) {
      if (censorImages && widget.entity.type != .user) {
        imageWidget = ClipRect(
          child: Stack(
            fit: .passthrough,
            children: [
              imageWidget,
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (_, constraints) => BackdropFilter(
                    filter: .blur(
                      sigmaX: constraints.maxWidth / 30,
                      sigmaY: constraints.maxWidth / 30,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const .all(4),
                        child: Stack(
                          children: [
                            AutoSizeText(
                              'Image hidden due to copyright',
                              textAlign: .center,
                              minFontSize: 4,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: .bold,
                                foreground: Paint()
                                  ..style = .stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                            ),
                            const AutoSizeText(
                              'Image hidden due to copyright',
                              textAlign: .center,
                              minFontSize: 4,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: .bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
  static const _iconMap = <EntityType, IconData>{
    .track: Icons.music_note,
    .album: Icons.album,
    .artist: Icons.people,
    .user: Icons.person,
    .playlist: Icons.queue_music,
  };

  final Entity entity;
  final ImageQuality quality;
  final double width;

  _Placeholder(this.entity, this.quality, double? width)
    : width = width ?? quality.width;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: .contain,
    child: Container(
      color: Theme.of(context).brightness == .light
          ? Colors.grey
          : Colors.grey.shade800,
      width: width,
      height: width,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.7,
          heightFactor: 0.7,
          child: FittedBox(
            child: Icon(_iconMap[entity.type], color: Colors.white),
          ),
        ),
      ),
    ),
  );
}
