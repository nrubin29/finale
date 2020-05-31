import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/types/generic.dart';

typedef DisplayableGetter = Future<List<Displayable>> Function(
    String username, int page);

enum DisplayType { list, grid }

class DisplayComponent extends StatefulWidget {
  final String username;
  final DisplayableGetter getter;
  final DisplayType displayType;

  DisplayComponent(
      {Key key,
      @required this.username,
      @required this.getter,
      this.displayType = DisplayType.list})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisplayComponentState();
}

class _DisplayComponentState extends State<DisplayComponent>
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

  Widget _listItemBuilder(BuildContext context, int index) {
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
  }

  @override
  bool get wantKeepAlive => true;
}
