import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/collage/collage_view.dart';
import 'package:finale/widgets/tools/workout_view.dart';
import 'package:flutter/material.dart';

class ToolsView extends StatelessWidget {
  const ToolsView();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar('Tools'),
        body: ListView(
          children: [
            CaptionedListTile(
              title: 'Collage Generator',
              icon: Icons.grid_view,
              trailing: const Icon(Icons.chevron_right),
              caption:
                  'Generate grids and lists of your top albums, artists, and '
                  'tracks over various time periods.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CollageView()),
                );
              },
            ),
            CaptionedListTile(
              title: 'Strava Workouts',
              icon: SocialMediaIcons.strava,
              trailing: const Icon(Icons.chevron_right),
              caption:
                  'Log in with Strava to see what tracks you listened to on '
                  'your workouts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutView()),
                );
              },
            ),
          ],
        ),
      );
}
