import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/views/login_view.dart';
import 'package:finale/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await QuickActionsManager.setup();
  await Preferences().setup();
  await ImageIdCache().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ScreenshotController? screenshotController;

  const MyApp([this.screenshotController]);

  @override
  Widget build(BuildContext context) {
    final name = Preferences().name;
    final home = name == null ? LoginView() : MainView(username: name);

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
        timePickerTheme:
            TimePickerThemeData(backgroundColor: ColorScheme.dark().background),
        switchTheme: SwitchThemeData(
            thumbColor: MaterialStateColor.resolveWith((_) => Colors.red),
            trackColor:
                MaterialStateColor.resolveWith((_) => Colors.red.shade200)),
      ),
      home: screenshotController != null
          ? Screenshot(child: home, controller: screenshotController!)
          : home,
    );
  }
}
