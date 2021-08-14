import 'package:finale/util/image_id_cache.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:finale/widgets/settings/about_view.dart';
import 'package:finale/widgets/settings/accounts_settings_view.dart';
import 'package:finale/widgets/settings/listen_continuously_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Builder(
            builder: (context) => Column(
                  children: [
                    ListTile(
                      title: Text('About'),
                      leading: Icon(Icons.info),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutView()));
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
                        title: Text('Listen Continuously'),
                        leading: Icon(Icons.all_inclusive),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ListenContinuouslySettingsView()));
                        },
                      ),
                    ListTile(
                      title: Text('Empty image cache'),
                      leading: Icon(Icons.delete),
                      onTap: () async {
                        await DefaultCacheManager().emptyCache();
                        await ImageIdCache().drop();

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('Success'),
                                  content: Text('Image cache emptied.'),
                                  actions: [
                                    TextButton(
                                        child: Text('Dismiss'),
                                        onPressed: () => Navigator.pop(context))
                                  ],
                                ));
                      },
                    ),
                    ListTile(
                        title: Text('Log out'),
                        leading: Icon(Icons.logout),
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
