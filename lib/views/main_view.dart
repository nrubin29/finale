import 'dart:async';

import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/views/collage_view.dart';
import 'package:finale/views/profile_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:finale/views/search_view.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  final String username;

  const MainView({required this.username});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _index = 0;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = QuickActionsManager.quickActionStream.listen((_) {
      setState(() {
        Navigator.popUntil(context, (route) => route.isFirst);
        _index = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Scrobble'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: 'Collage'),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          ProfileView(username: widget.username, isTab: true),
          SearchView(),
          ScrobbleView(),
          CollageView(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
