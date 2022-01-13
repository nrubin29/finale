import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:finale/widgets/main/main_view.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences().setup();

  if (isMobile) {
    await QuickActionsManager().setup();
  }

  if (!isWeb) {
    await ImageIdCache().setup();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeColor _themeColor;

  @override
  void initState() {
    super.initState();

    Preferences().themeColorChange.listen((value) {
      setState(() {
        _themeColor = value;
      });
    });

    _themeColor = Preferences().themeColor;
  }

  @override
  Widget build(BuildContext context) {
    final name = Preferences().name;

    return MaterialApp(
      title: 'Finale',
      theme: FinaleTheme.lightFor(_themeColor),
      darkTheme: FinaleTheme.darkFor(_themeColor),
      home: name == null ? LoginView() : MainView(username: name),
    );
  }
}
