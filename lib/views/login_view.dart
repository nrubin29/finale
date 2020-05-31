import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simplescrobble/lastfm.dart';
import 'package:simplescrobble/views/main_view.dart';

import '../env.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Center(
          child: RaisedButton(
            onPressed: () async {
              final result = await FlutterWebAuth.authenticate(
                  url: Uri.https('last.fm', 'api/auth',
                      {'api_key': apiKey, 'cb': 'scrobble://auth'}).toString(),
                  callbackUrlScheme: 'scrobble');
              final token = Uri.parse(result).queryParameters['token'];
              final session = await Lastfm.authenticate(token);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('name', session.name);
              await prefs.setString('key', session.key);

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainView(username: session.name)));
            },
            color: Colors.red,
            child: Text('Log in with Last.fm',
                style: TextStyle(color: Colors.white)),
          ),
        ));
  }
}
