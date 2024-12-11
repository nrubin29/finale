import 'package:finale/util/background_tasks/background_task_manager.dart'
    as background_task_manager;
import 'package:finale/util/constants.dart';
import 'package:finale/util/external_actions/notifications.dart'
    as notifications;
import 'package:finale/util/external_actions/quick_actions_manager.dart'
    as quick_actions_manager;
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preference.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/entity/lastfm/profile_stack.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:finale/widgets/main/main_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preference.setup();

  if (isMobile) {
    await quick_actions_manager.setup();
    await background_task_manager.setup();
    await notifications.setup();
  }

  if (!isWeb) {
    await ImageIdCache().setup();
  }

  runApp(ProfileStack(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeColor _themeColor;
  late bool _offBlackBackground;

  @override
  void initState() {
    super.initState();

    Preferences.themeColor.changes.listen((value) {
      setState(() {
        _themeColor = value;
      });
    });

    Preferences.themeBackground.changes.listen((value) {
      setState(() {
        _offBlackBackground = value;
      });
    });

    _themeColor = Preferences.themeColor.value;
    _offBlackBackground = Preferences.themeBackground.value;
  }

  @override
  Widget build(BuildContext context) {
    final name = Preferences.name.value;
    return MaterialApp(
      title: 'Finale',
      theme: finaleTheme(_themeColor, Brightness.light),
      darkTheme: finaleTheme(_themeColor, Brightness.dark, _offBlackBackground),
      home: name == null ? const LoginView() : MainView(username: name),
    );
  }
}
