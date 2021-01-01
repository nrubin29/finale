import 'package:finale/views/profile_view.dart';
import 'package:finale/views/scrobble_view.dart';
import 'package:finale/views/search_view.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  final String username;

  MainView({Key key, this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (int index) {
            setState(() {
              _index = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Scrobble'),
          ],
        ),
        body: IndexedStack(index: _index, children: [
          ProfileView(username: widget.username, isTab: true),
          SearchView(),
          ScrobbleView(),
        ]));
  }
}
