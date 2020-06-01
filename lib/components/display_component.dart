import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/types/generic.dart';

enum DisplayType { list, grid }

class DisplayComponent<T extends Displayable> extends StatefulWidget {
  final PagedLastfmRequest<T> request;
  final Stream<PagedLastfmRequest<T>> requestStream;

  final void Function(T item) secondaryAction;

  final DisplayType displayType;

  DisplayComponent(
      {Key key,
      this.request,
      this.requestStream,
      this.secondaryAction,
      this.displayType = DisplayType.list})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisplayComponentState<T>();
}

class _DisplayComponentState<T extends Displayable>
    extends State<DisplayComponent>
    with AutomaticKeepAliveClientMixin {
  var items = List<T>();
  int page = 1;

  final _scrollController = ScrollController();

  PagedLastfmRequest<T> _request;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreItems();
      }
    });

    if (widget.request != null) {
      _request = widget.request;
      _getInitialItems();
    } else {
      _subscription = widget.requestStream?.listen((newRequest) {
        setState(() {
          _request = newRequest;
          _getInitialItems();
        });
      });
    }
  }

  Future<void> _getInitialItems() async {
    final initialItems = await _request.doRequest(50, 1);
    setState(() {
      items = initialItems;
      page = 2;
    });
  }

  Future<void> _getMoreItems() async {
    final moreItems = await _request.doRequest(50, page);
    setState(() {
      items.addAll(moreItems);
      page += 1;
    });
  }

  Widget _listItemBuilder(BuildContext context, int index) {
    final item = items[index];
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(item.displayTitle),
      subtitle:
      item.displaySubtitle != null ? Text(item.displaySubtitle) : null,
      leading:
      item.images != null ? Image.network(item.images.first.url) : null,
      trailing: item.displayTrailing != null
          ? Text(item.displayTrailing,
          style: TextStyle(color: Colors.grey, fontSize: 12))
          : widget.secondaryAction != null
          ? IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            widget.secondaryAction(item);
          })
          : null,
    );
  }

  Widget _gridItemBuilder(BuildContext context, int index) {
    final item = items[index];
    return GridTile(
      footer: Container(
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.displayTitle,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              if (item.displaySubtitle != null)
                Text(item.displaySubtitle, style: TextStyle(fontSize: 13)),
              if (item.displayTrailing != null)
                Text(item.displayTrailing, style: TextStyle(fontSize: 13))
            ],
          )),
      child: Stack(
        children: [
          Image.network(item.images.last.url),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.grey.withOpacity(0),
                    Colors.black.withOpacity(0.75)
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (items.isEmpty) {
      return CircularProgressIndicator();
    }

    return RefreshIndicator(
        onRefresh: _getInitialItems,
        child: widget.displayType == DisplayType.list
            ? ListView.builder(
            controller: _scrollController,
            itemCount: items.length,
            itemBuilder: _listItemBuilder)
            : GridView.builder(
            controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: items.length,
            itemBuilder: _gridItemBuilder));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _subscription.cancel();
  }

  @override
  bool get wantKeepAlive => true;
}
