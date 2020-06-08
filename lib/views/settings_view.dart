import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplescrobble/views/about_view.dart';
import 'package:simplescrobble/views/login_view.dart';

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
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutView()));
                      },
                    ),
                    ListTile(
                      title: Text('Empty image cache'),
                      onTap: () {
                        DefaultCacheManager().emptyCache();

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('Success'),
                                  content: Text('Image cache emptied.'),
                                  actions: [
                                    FlatButton(
                                        child: Text('Dismiss'),
                                        onPressed: () => Navigator.pop(context))
                                  ],
                                ));
                      },
                    ),
                    ListTile(
                        title: Text('Log out'),
                        onTap: () async {
                          await (await SharedPreferences.getInstance()).clear();
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
