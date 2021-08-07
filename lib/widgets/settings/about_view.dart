import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:social_media_buttons/social_media_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('About'),
      body: CustomScrollView(
        physics: const ScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                appIcon(size: 84),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finale', style: TextStyle(fontSize: 24)),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (_, snapshot) => snapshot.hasData
                          ? Text('Version ${snapshot.data!.fullVersion}')
                          : SizedBox(),
                    )
                  ],
                )
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(text: 'Made with '),
                  WidgetSpan(
                    child: Icon(
                      Icons.favorite,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    child: Icon(
                      Icons.music_note,
                      size: 16,
                    ),
                  ),
                  TextSpan(text: ' by Noah Rubin'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('Follow me on Twitter'),
              leading: Icon(SocialMediaIcons.twitter),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch('https://twitter.com/nrubin29');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('My website'),
              leading: Icon(Icons.web),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch('https://nrubintech.com');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('Source code'),
              leading: Icon(SocialMediaIcons.github_circled),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch('https://github.com/nrubin29/finale');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('Send feedback'),
              leading: Icon(Icons.email),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch('mailto:feedback@finale.app'
                    '?subject=Finale%20feedback');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('Privacy policy'),
              leading: Icon(Icons.privacy_tip),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                launch('https://finale.app/privacy');
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('\u00a9 2021 Noah Rubin Technologies LLC'),
                  Text('All rights reserved'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
