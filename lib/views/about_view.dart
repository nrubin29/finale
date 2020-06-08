import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('About')),
        body: Builder(
            builder: (context) => Center(
                    child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/images/icon.png',
                                width: 96)),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text(
                              'simplescrobble',
                              style: TextStyle(fontSize: 24),
                            ),
                            FutureBuilder(
                                future: PackageInfo.fromPlatform()
                                    .then((info) => info.version),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? Text('Version ${snapshot.data}')
                                    : SizedBox())
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    RichText(
                        text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText2,
                            children: [
                          TextSpan(text: 'Created with '),
                          WidgetSpan(
                              child: Icon(
                            Icons.favorite,
                            size: 16,
                          )),
                          TextSpan(text: ' and '),
                          WidgetSpan(
                              child: Icon(
                            Icons.music_note,
                            size: 16,
                          )),
                          TextSpan(text: ' by Noah Rubin')
                        ])),
                    SizedBox(height: 10),
                    Text('\u00a9 2020 Noah Rubin Technologies LLC'),
                    Text('All rights reserved'),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text('Author\'s website'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        launch('https://nrubintech.com');
                      },
                    ),
                    ListTile(
                        title: Text('View source on GitHub'),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          launch(
                              'https://github.com/nrubin29/simplescrobble-mobile');
                        })
                  ],
                ))));
  }
}
