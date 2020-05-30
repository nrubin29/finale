import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplescrobble/views/profile_view.dart';
import 'package:simplescrobble/views/search_view.dart';

class MainView extends StatefulWidget {
  final String username;

  MainView({Key key, this.username}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainViewState(username);
}

class _MainViewState extends State<MainView> {
  final String _username;
  int _index = 0;

  _MainViewState(this._username);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        floatingActionButton: FloatingActionButton(
//          onPressed: () {},
//          backgroundColor: Colors.red,
//          child: Icon(Icons.add, color: Colors.white),
//        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (int index) {
            setState(() {
              _index = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text('Profile')),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text('Search'))
          ],
        ),
        body: IndexedStack(index: _index, children: [
          ProfileView(username: _username),
          SearchView(),
        ]));
  }
}
