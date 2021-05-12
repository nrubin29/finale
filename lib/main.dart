// @dart=2.9

import 'package:finale/cache.dart';
import 'package:finale/views/error_view.dart';
import 'package:finale/views/login_view.dart';
import 'package:finale/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImageIdCache().setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Finale',
        theme: ThemeData.from(
                colorScheme: ColorScheme.light(
                    primary: Colors.red,
                    secondary: Colors.red,
                    surface: Colors.red))
            .copyWith(
                timePickerTheme: TimePickerThemeData(
                    backgroundColor: ColorScheme.light().background)),
        darkTheme: ThemeData.from(
                colorScheme: ColorScheme.dark(
                    primary: Colors.red,
                    secondary: Colors.red,
                    surface: Colors.red))
            .copyWith(
                timePickerTheme: TimePickerThemeData(
                    backgroundColor: ColorScheme.dark().background),
                switchTheme: SwitchThemeData(
                    thumbColor:
                        MaterialStateColor.resolveWith((_) => Colors.red),
                    trackColor: MaterialStateColor.resolveWith(
                        (_) => Colors.red.shade200))),
        home: FutureBuilder<String>(
            future: SharedPreferences.getInstance().then((value) => value.getString('name')),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error);
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
