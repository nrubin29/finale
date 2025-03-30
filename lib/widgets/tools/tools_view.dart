import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/captioned_list_tile.dart';
import 'package:finale/widgets/collage/collage_view.dart';
import 'package:finale/widgets/entity/lastfm/cookie_dialog.dart';
import 'package:finale/widgets/tools/h_index_view.dart';
import 'package:finale/widgets/tools/lucky_view.dart';
import 'package:finale/widgets/tools/scrobble_manager/scrobble_manager_view.dart';
import 'package:finale/widgets/tools/workout_view.dart';
import 'package:flutter/material.dart';

class ToolsView extends StatelessWidget {
  const ToolsView();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Tools'),
    body: ListView(
      children: [
        CaptionedListTile(
          title: 'Collage Generator',
          icon: Icons.grid_view,
          trailing: const Icon(Icons.chevron_right),
          caption:
              'Generate personalized images of your top albums, artists, '
              'and tracks over various time periods.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CollageView()),
            );
          },
        ),
        if (isMobile)
          CaptionedListTile(
            title: 'Scrobble Manager',
            icon: Icons.edit,
            trailing: const Icon(Icons.chevron_right),
            caption: 'Edit and delete scrobbles.',
            onTap: () async {
              if (!await LastfmCookie.hasCookies()) {
                if (!context.mounted) return;
                if (!await showCookieDialog(context)) {
                  return;
                }
              }

              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScrobbleManagerView()),
              );
            },
          ),
        CaptionedListTile(
          title: "I'm Feeling Lucky",
          icon: Icons.casino,
          trailing: const Icon(Icons.chevron_right),
          caption:
              "Pick a random artist, album, or track from your (or a "
              "friend's) library.",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LuckyView()),
            );
          },
        ),
        CaptionedListTile(
          title: 'h-index',
          icon: Icons.read_more,
          trailing: const Icon(Icons.chevron_right),
          caption:
              "Calculate your (or a friend's) h-index for artists, albums, "
              'or tracks over various time periods.',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HIndexView()),
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
