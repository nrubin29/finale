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
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                appIcon(size: 84),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Finale', style: TextStyle(fontSize: 24)),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (_, snapshot) => snapshot.hasData
                          ? Text('Version ${snapshot.data!.fullVersion}')
                          : const SizedBox(),
                    )
                  ],
                )
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyText2,
                children: const [
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
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Follow me on Twitter'),
              leading: const Icon(SocialMediaIcons.twitter),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launch('https://twitter.com/nrubin29');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('My website'),
              leading: const Icon(Icons.web),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launch('https://nrubintech.com');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Source code'),
              leading: const Icon(SocialMediaIcons.github_circled),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launch('https://github.com/nrubin29/finale');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Send feedback'),
              leading: const Icon(Icons.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launch('mailto:feedback@finale.app'
                    '?subject=Finale%20feedback');
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Privacy policy'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.chevron_right),
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
                children: const [
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
