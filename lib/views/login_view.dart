import 'dart:math';

import 'package:finale/components/image_component.dart';
import 'package:finale/constants.dart';
import 'package:finale/env.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatelessWidget {
  void _logIn(BuildContext context) async {
    final result = await FlutterWebAuth.authenticate(
        url: Uri.https('last.fm', 'api/auth',
            {'api_key': apiKey, 'cb': 'finale://auth'}).toString(),
        callbackUrlScheme: 'finale');
    final token = Uri.parse(result).queryParameters['token'];
    final session = await Lastfm.authenticate(token);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', session.name);
    await prefs.setString('key', session.key);

    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainView(username: session.name)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            FutureBuilder<List<LTopArtistsResponseArtist>>(
              future: Lastfm.getGlobalTopArtists(50),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }

                return GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  crossAxisCount:
                      max(MediaQuery.of(context).size.width ~/ 200, 3),
                  children: snapshot.data
                      .map((artist) => FutureBuilder<List<LArtistTopAlbum>>(
                          future: ArtistGetTopAlbumsRequest(artist.name)
                              .doRequest(1, 1),
                          builder: (context, snapshot) => snapshot.hasData
                              ? ImageComponent(
                                  displayable: snapshot.data.first,
                                  showPlaceholder: false)
                              : Container()))
                      .toList(),
                );
              },
            ),
            Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(2 / 3))),
            Center(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(0.9),
                        border: Border.all(),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    child: IntrinsicHeight(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Finale',
                            style: Theme.of(context)
                                .textTheme
                                .headline2
                                .copyWith(color: Colors.white)),
                        SizedBox(height: 10),
                        Text('A fully-featured Last.fm client and scrobbler',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: Colors.white)),
                        SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => _logIn(context),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getLastfmIcon(Colors.white),
                              SizedBox(width: 8),
                              Text('Log in with Last.fm',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(color: Colors.white))
                            ],
                          ),
                        )
                      ],
                    )))),
          ],
        ));
  }
}
