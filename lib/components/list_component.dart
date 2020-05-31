import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/types/generic.dart';

typedef DisplayableGetter = Future<List<Displayable>> Function(
    String name, int page);

class ListComponent extends StatefulWidget {
  final String username;
  final DisplayableGetter getter;

  ListComponent({Key key, @required this.username, @required this.getter})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListComponentState();
}

class _ListComponentState extends State<ListComponent>
    with AutomaticKeepAliveClientMixin {
  var items = List<Displayable>();
  int page = 1;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getInitialItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreItems();
      }
    });
  }

  Future<void> _getInitialItems() async {
    final initialItems = await widget.getter(widget.username, 1);
    setState(() {
      items = initialItems;
      page = 2;
    });
  }

  Future<void> _getMoreItems() async {
    final moreItems = await widget.getter(widget.username, page);
    setState(() {
      items.addAll(moreItems);
      page += 1;
    });
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = items[index];
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(item.displayTitle),
      subtitle:
          item.displaySubtitle != null ? Text(item.displaySubtitle) : null,
      leading: Image.network(item.images.first.url),
      trailing: item.displayTrailing != null
          ? Text(item.displayTrailing,
              style: TextStyle(color: Colors.grey, fontSize: 12))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return CircularProgressIndicator();
    }

    return RefreshIndicator(
        onRefresh: _getInitialItems,
        child: ListView.builder(
            controller: _scrollController,
            itemCount: items.length,
            itemBuilder: _itemBuilder));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
