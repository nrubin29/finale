import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:social_media_buttons/social_media_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('About')),
        body: Builder(
            builder: (context) => Center(
                    child: SafeArea(
                        child: Column(
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/images/icon.png',
                                width: 84)),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Finale',
                              style: TextStyle(fontSize: 24),
                            ),
                            FutureBuilder<PackageInfo>(
                                future: PackageInfo.fromPlatform(),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? Text(
                                        'Version ${snapshot.data!.version}+${snapshot.data!.buildNumber}')
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
                          TextSpan(text: 'Made with '),
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
                    ListTile(
                      title: Text('Follow me on Twitter'),
                      leading: Icon(SocialMediaIcons.twitter),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        launch('https://twitter.com/nrubin29');
                      },
                    ),
                    ListTile(
                      title: Text('My website'),
                      leading: Icon(Icons.web),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        launch('https://nrubintech.com');
                      },
                    ),
                    ListTile(
                        title: Text('Source code'),
                        leading: Icon(SocialMediaIcons.github_circled),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          launch('https://github.com/nrubin29/finale');
                        }),
                    ListTile(
                      title: Text('Send feedback'),
                      leading: Icon(Icons.email),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        launch(
                            'mailto:nrubin29@gmail.com?subject=Finale%20feedback');
                      },
                    ),
                    Spacer(),
                    Text('\u00a9 2021 Noah Rubin Technologies LLC'),
                    Text('All rights reserved'),
                  ],
                )))));
  }
}
