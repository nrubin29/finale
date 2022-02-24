import 'package:finale/util/constants.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:finale/widgets/settings/about_view.dart';
import 'package:finale/widgets/settings/accounts_settings_view.dart';
import 'package:finale/widgets/settings/general_settings_view.dart';
import 'package:finale/widgets/settings/listen_continuously_settings_view.dart';
import 'package:finale/widgets/settings/theme_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Builder(
            builder: (context) => ListView(
                  children: [
                    ListTile(
                      title: const Text('About'),
                      leading: const Icon(Icons.info),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutView()));
                      },
                    ),
                    ListTile(
                      title: const Text('General'),
                      leading: const Icon(Icons.settings),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GeneralSettingsView()),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('Accounts'),
                      leading: const Icon(Icons.switch_account),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AccountsSettingsView()));
                      },
                    ),
                    if (isMobile)
                      ListTile(
                        title: const Text('Listen Continuously'),
                        leading: const Icon(Icons.all_inclusive),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ListenContinuouslySettingsView()));
                        },
                      ),
                    ListTile(
                      title: const Text('Theme'),
                      leading: const Icon(Icons.format_paint),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ThemeSettingsView()),
                        );
                      },
                    ),
                    if (!isWeb)
                      ListTile(
                        title: const Text('Empty image cache'),
                        leading: const Icon(Icons.delete),
                        onTap: () async {
                          await DefaultCacheManager().emptyCache();
                          await ImageIdCache().drop();

                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('Success'),
                                    content: const Text('Image cache emptied.'),
                                    actions: [
                                      TextButton(
                                          child: const Text('Dismiss'),
                                          onPressed: () =>
                                              Navigator.pop(context))
                                    ],
                                  ));
                        },
                      ),
                    ListTile(
                        title: const Text('Log out'),
                        leading: const Icon(Icons.logout),
                        onTap: () {
                          Preferences().clear();
                          Navigator.popUntil(context, (route) => false);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginView()));
                        }),
                  ],
                )));
  }
}
