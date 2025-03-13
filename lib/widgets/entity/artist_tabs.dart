import 'package:flutter/material.dart';

class ArtistTabs extends StatefulWidget {
  final Widget albumsWidget;
  final Widget tracksWidget;
  final Widget? similarArtistsWidget;
  final Color? color;

  bool get hasSimilarArtists => similarArtistsWidget != null;

  const ArtistTabs({
    required this.albumsWidget,
    required this.tracksWidget,
    this.similarArtistsWidget,
    this.color,
  });

  @override
  State<StatefulWidget> createState() => _ArtistTabsState();
}

class _ArtistTabsState extends State<ArtistTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.hasSimilarArtists ? 3 : 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TabBar(
        labelColor: widget.color,
        indicatorColor: widget.color,
        controller: _tabController,
        tabs: [
          const Tab(icon: Icon(Icons.album)),
          const Tab(icon: Icon(Icons.audiotrack)),
          if (widget.hasSimilarArtists) const Tab(icon: Icon(Icons.people)),
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
          if (widget.hasSimilarArtists)
            Visibility(
              visible: _tabController.index == 2,
              maintainState: true,
              child: widget.similarArtistsWidget!,
            ),
        ],
      ),
    ],
  );
}
