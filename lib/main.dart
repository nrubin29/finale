import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplescrobble/components/error_component.dart';
import 'package:simplescrobble/views/login_view.dart';
import 'package:simplescrobble/views/main_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'simplescrobble',
        theme: ThemeData.from(
            colorScheme: ColorScheme.light(
                primary: Colors.red,
                secondary: Colors.red,
                surface: Colors.red)),
        darkTheme: ThemeData.from(
            colorScheme: ColorScheme.dark(
                primary: Colors.red,
                secondary: Colors.red,
                surface: Colors.red)),
        home: FutureBuilder<String>(
            future: SharedPreferences.getInstance()
                .then((value) => value.getString('name')),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorComponent(error: snapshot.error);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              } else if (snapshot.hasData) {
                return MainView(username: snapshot.data);
              } else {
                return LoginView();
              }
            }));
  }
}
