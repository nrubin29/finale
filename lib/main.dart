import 'package:flutter/material.dart';
import 'package:simplescrobble/views/profile_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'simplescrobble',
        theme:
            ThemeData.from(colorScheme: ColorScheme.light(primary: Colors.red)),
        home: ProfileView(username: 'nrubin29'));
  }
}
