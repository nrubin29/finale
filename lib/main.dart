import 'package:finale/cache.dart';
import 'package:finale/preferences.dart';
import 'package:finale/views/login_view.dart';
import 'package:finale/views/main_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences().setup();
  await ImageIdCache().setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = Preferences().name;

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
        home: name == null ? LoginView() : MainView(username: name));
  }
}
