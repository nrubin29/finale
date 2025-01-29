import 'package:finale/util/extensions.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  int get year => DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, 'About'),
      body: CustomScrollView(
        physics: const ScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(size: 84),
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
                style: Theme.of(context).textTheme.bodyMedium,
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
                launchUrl(Uri.https('x.com', 'nrubin29'));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('My website'),
              leading: const Icon(Icons.web),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launchUrl(Uri.https('noahzrubin.com'));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('r/FinaleApp'),
              leading: const Icon(SocialMediaIcons.reddit),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launchUrl(Uri.https('reddit.com', 'r/FinaleApp'));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Source code'),
              leading: const Icon(SocialMediaIcons.github),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launchUrl(Uri.https('github.com', 'nrubin29/finale'));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Privacy policy'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                launchUrl(Uri.https('finale.app', 'privacy'));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListTile(
              title: const Text('Licenses'),
              leading: const Icon(Icons.integration_instructions),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(context: context);
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
                  Text('\u00a9 2020-$year Noah Rubin Technologies LLC'),
                  const Text('All rights reserved'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
