import 'package:flutter/material.dart';

class ArtistTabs extends StatefulWidget {
  final Widget albumsWidget;
  final Widget tracksWidget;
  final Color? color;

  const ArtistTabs(
      {required this.albumsWidget, required this.tracksWidget, this.color});

  @override
  State<StatefulWidget> createState() => _ArtistTabsState();
}

class _ArtistTabsState extends State<ArtistTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    return Column(
        children: [
          TabBar(
            labelColor: color,
            unselectedLabelColor: Colors.grey,
            indicatorColor: color,
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.album)),
              Tab(icon: Icon(Icons.audiotrack)),
            ],
            onTap: (index) {
              setState(() {
                _tabController.animateTo(index);
              });
            },
          ),
          IndexedStack(
            index: _tabController.index,
            children: [
              Visibility(
                visible: _tabController.index == 0,
                maintainState: true,
                child: widget.albumsWidget,
              ),
              Visibility(
                visible: _tabController.index == 1,
                maintainState: true,
                child: widget.tracksWidget,
              ),
            ],
          ),
        ],
      );
  }
}
