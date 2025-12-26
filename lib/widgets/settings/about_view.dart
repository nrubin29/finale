import 'package:finale/util/extensions.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  final year = DateTime.now().year;

  Widget _listTile({
    required String title,
    required IconData icon,
    required void Function() onTap,
  }) => SliverToBoxAdapter(
    child: ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(context, 'About'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: CustomScrollView(
            physics: const ScrollPhysics(),
            slivers: [
              const SliverPadding(padding: .only(top: 24)),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: .center,
                  spacing: 18,
                  children: [
                    const AppIcon(size: 92),
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        const Text('Finale', style: TextStyle(fontSize: 32)),
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (_, snapshot) => snapshot.hasData
                              ? Text(
                                  'v${snapshot.data!.fullVersion}',
                                  style: const TextStyle(fontSize: 18),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SliverPadding(padding: .only(top: 18)),
              SliverToBoxAdapter(
                child: RichText(
                  textAlign: .center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: const [
                      TextSpan(text: 'Made with '),
                      WidgetSpan(child: Icon(Icons.favorite, size: 16)),
                      TextSpan(text: ' and '),
                      WidgetSpan(child: Icon(Icons.music_note, size: 16)),
                      TextSpan(text: ' by Noah Rubin'),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: .only(top: 18)),
              _listTile(
                title: 'My website',
                icon: Icons.web,
                onTap: () {
                  launchUrl(.https('noahzrubin.com'));
                },
              ),
              _listTile(
                title: 'Follow me on Twitter',
                icon: SocialMediaIcons.twitter,
                onTap: () {
                  launchUrl(.https('x.com', 'nrubin29'));
                },
              ),
              _listTile(
                title: 'r/FinaleApp',
                icon: SocialMediaIcons.reddit,
                onTap: () {
                  launchUrl(.https('reddit.com', 'r/FinaleApp'));
                },
              ),
              _listTile(
                title: 'Source code',
                icon: SocialMediaIcons.github,
                onTap: () {
                  launchUrl(.https('github.com', 'nrubin29/finale'));
                },
              ),
              _listTile(
                title: 'Privacy policy',
                icon: Icons.privacy_tip,
                onTap: () {
                  launchUrl(.https('finale.app', 'privacy'));
                },
              ),
              _listTile(
                title: 'Licenses',
                icon: Icons.integration_instructions,
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: SafeArea(
                  minimum: const .only(bottom: 24),
                  child: Column(
                    mainAxisSize: .min,
                    mainAxisAlignment: .end,
                    children: [
                      Text('\u00a9 2020-$year Noah Rubin Technologies LLC'),
                      const Text('All rights reserved'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
