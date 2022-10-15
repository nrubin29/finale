import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/period_paged_request.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/error_component.dart';
import 'package:finale/widgets/base/loading_component.dart';
import 'package:finale/widgets/entity/entity_display_controller.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/scrobble/scrobble_button.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

enum DisplayType { list, grid }

typedef OnTap<T extends Entity> = void Function(T item);

typedef EntityWidgetBuilder<T extends Entity> = Widget Function(T item);

typedef EntityAndItemsWidgetBuilder<T extends Entity> = Widget Function(
    T item, List<T> items);

class EntityDisplay<T extends Entity> extends StatefulWidget {
  final EntityDisplayController<T>? controller;
  final List<T>? items;
  final PagedRequest<T>? request;
  final Stream<PagedRequest<T>>? requestStream;

  final OnTap<T>? onTap;
  final EntityWidgetBuilder<T>? detailWidgetBuilder;
  final EntityAndItemsWidgetBuilder<T>? subtitleWidgetBuilder;
  final EntityWidgetBuilder<T>? leadingWidgetBuilder;
  final EntityWidgetBuilder<T>? badgeWidgetBuilder;
  final EntityWidgetBuilder<T>? trailingWidgetBuilder;
  final List<Widget>? slivers;
  final Future<Entity> Function(T item)? scrobbleableEntity;
  final RefreshCallback? onRefresh;

  final DisplayType displayType;
  final bool scrollable;
  final bool displayNumbers;
  final bool displayImages;
  final bool shouldLeftPadListItems;
  final PlaceholderBehavior placeholderBehavior;
  final bool displayCircularImages;
  final String? noResultsMessage;
  final bool showGridTileGradient;
  final double gridTileSize;
  final double gridTileTextPadding;
  final double fontSize;

  const EntityDisplay(
      {this.controller,
      this.items,
      this.request,
      this.requestStream,
      this.onTap,
      this.detailWidgetBuilder,
      this.subtitleWidgetBuilder,
      this.leadingWidgetBuilder,
      this.badgeWidgetBuilder,
      this.trailingWidgetBuilder,
      this.slivers,
      this.scrobbleableEntity,
      this.onRefresh,
      this.displayType = DisplayType.list,
      this.scrollable = true,
      this.displayNumbers = false,
      this.displayImages = true,
      this.shouldLeftPadListItems = true,
      this.placeholderBehavior = PlaceholderBehavior.image,
      this.displayCircularImages = false,
      this.noResultsMessage = 'No results.',
      this.showGridTileGradient = true,
      this.gridTileSize = 250,
      this.gridTileTextPadding = 16,
      this.fontSize = 14})
      : assert(controller != null ||
            items != null ||
            request != null ||
            requestStream != null),
        assert(onTap == null || detailWidgetBuilder == null),
        assert(displayType == DisplayType.list ||
            (!displayNumbers && leadingWidgetBuilder == null)),
        assert(badgeWidgetBuilder == null || displayImages);

  @override
  State<StatefulWidget> createState() => EntityDisplayState<T>();
}

class EntityDisplayState<T extends Entity> extends State<EntityDisplay<T>>
    with AutomaticKeepAliveClientMixin {
  EntityDisplayController<T>? _managedController;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _setUpController();
  }

  void _setUpController() {
    _managedController?.dispose();

    if (widget.controller == null) {
      if (widget.items != null) {
        _managedController = EntityDisplayController.forItems(widget.items!);
      } else if (widget.request != null) {
        _managedController =
            EntityDisplayController.forRequest(widget.request!);
      } else {
        _managedController =
            EntityDisplayController.forRequestStream(widget.requestStream!);
      }
    }

    _subscription?.cancel();
    _subscription = _controller.changes.listen((_) {
      setState(() {});
    });

    _controller.getInitialItems();
  }

  EntityDisplayController<T> get _controller =>
      widget.controller ?? _managedController!;

  void _onTap(T item) {
    assert(widget.onTap != null || widget.detailWidgetBuilder != null);

    if (widget.onTap != null) {
      widget.onTap!(item);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget.detailWidgetBuilder!(item)),
      );
    }
  }

  Widget _listItemBuilder(BuildContext context, int index) {
    final item = _controller.items[index];
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(item.displayTitle),
      contentPadding: widget.shouldLeftPadListItems
          ? null
          : const EdgeInsets.only(right: 16),
      onTap: widget.onTap != null || widget.detailWidgetBuilder != null
          ? () {
              _onTap(item);
            }
          : null,
      subtitle: item.displaySubtitle != null ||
              widget.subtitleWidgetBuilder != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.displaySubtitle != null) Text(item.displaySubtitle!),
                if (widget.subtitleWidgetBuilder != null)
                  widget.subtitleWidgetBuilder!(item, _controller.items),
              ],
            )
          : null,
      leading: widget.leadingWidgetBuilder != null ||
              widget.displayImages ||
              widget.displayNumbers
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.leadingWidgetBuilder != null)
                  widget.leadingWidgetBuilder!(item),
                if (widget.displayImages)
                  Stack(
                    alignment: const Alignment(1.5, -1.5),
                    children: [
                      EntityImage(
                        entity: item,
                        isCircular: widget.displayCircularImages,
                        placeholderBehavior: widget.placeholderBehavior,
                      ),
                      if (widget.badgeWidgetBuilder != null)
                        widget.badgeWidgetBuilder!(item),
                    ],
                  ),
                if (widget.displayNumbers) Text('${index + 1}'),
              ],
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.displayTrailing != null)
            Text(
              item.displayTrailing!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          if (widget.trailingWidgetBuilder != null)
            widget.trailingWidgetBuilder!(item),
          if (widget.scrobbleableEntity != null)
            ScrobbleButton(
                entityProvider: () => widget.scrobbleableEntity!(item)),
        ],
      ),
    );
  }

  Widget _gridTileBuilder(BuildContext context, int index) {
    final item = _controller.items[index];
    return GridTile(
      header: widget.scrobbleableEntity != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ScrobbleButton(
                    entityProvider: () => widget.scrobbleableEntity!(item),
                    color: Colors.white),
              ],
            )
          : null,
      footer: Container(
          margin: EdgeInsets.all(widget.gridTileTextPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.fontSize > 0)
                Text(
                  item.displayTitle,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              if (item.displaySubtitle != null)
                Text(
                  item.displaySubtitle!,
                  style: TextStyle(
                    fontSize: widget.fontSize - 1,
                    color: Colors.white,
                  ),
                ),
              if (item.displayTrailing != null)
                Text(
                  item.displayTrailing!,
                  style: TextStyle(
                    fontSize: widget.fontSize - 1,
                    color: Colors.white,
                  ),
                ),
            ],
          )),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.displayImages)
            EntityImage(
              entity: item,
              quality: ImageQuality.high,
              fit: BoxFit.cover,
              placeholderBehavior: widget.placeholderBehavior,
            ),
          if (widget.showGridTileGradient)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gridItemBuilder(BuildContext context, int index) {
    if (widget.onTap != null || widget.detailWidgetBuilder != null) {
      return InkWell(
          onTap: () {
            _onTap(_controller.items[index]);
          },
          child: _gridTileBuilder(context, index));
    }

    return _gridTileBuilder(context, index);
  }

  Widget _mainBuilder(BuildContext context) {
    if (_controller.hasException || _controller.items.isEmpty) {
      // The Stack is a hack to make the RefreshIndicator work.
      return Stack(children: [
        ListView(),
        if (_controller.hasException)
          ErrorComponent(
            error: _controller.exception!,
            stackTrace: _controller.stackTrace!,
            detailObject: _controller.request,
          )
        else if (widget.noResultsMessage != null)
          Center(child: Text(widget.noResultsMessage!)),
      ]);
    }

    return CustomScrollView(
        physics: widget.scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: !widget.scrollable,
        slivers: [
          ...?widget.slivers,
          if (widget.displayType == DisplayType.list)
            SliverList(
                delegate: SliverChildBuilderDelegate(_listItemBuilder,
                    childCount: _controller.items.length)),
          if (widget.displayType == DisplayType.grid)
            SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: widget.gridTileSize),
                delegate: SliverChildBuilderDelegate(_gridItemBuilder,
                    childCount: _controller.items.length)),
          if (_controller.isBackedByRequest && _controller.hasMorePages)
            SliverVisibilityDetector(
              key: UniqueKey(),
              sliver: SliverToBoxAdapter(
                child: SafeArea(
                  child: _controller.isDoingRequest
                      ? const ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Loading...'),
                        )
                      : const ListTile(
                          leading: Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.arrow_upward, size: 36),
                          ),
                          title: Text('Scroll to load more items'),
                        ),
                ),
              ),
              onVisibilityChanged: (visibilityInfo) {
                if (visibilityInfo.visibleFraction > 0.95) {
                  _controller.getMoreItems();
                }
              },
            )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_controller.didInitialRequest) {
      String? message;

      if (_controller.request is PeriodPagedRequest) {
        final request = _controller.request as PeriodPagedRequest;
        if ((request.period ?? Preferences.period.value).isCustom) {
          message = 'Custom date ranges can take a long time to load.';
        }
      }

      return LoadingComponent(message: message);
    }

    if (!_controller.isBackedByRequest && widget.onRefresh == null) {
      return _mainBuilder(context);
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh != null
          ? widget.onRefresh!
          : _controller.getInitialItems,
      child: _mainBuilder(context),
    );
  }

  @override
  void didUpdateWidget(covariant EntityDisplay<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller ||
        widget.items != null && widget.items != oldWidget.items) {
      _setUpController();
    }
  }

  @override
  void dispose() {
    _managedController?.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
