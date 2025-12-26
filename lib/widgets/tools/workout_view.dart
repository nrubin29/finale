import 'package:finale/services/strava/activity.dart';
import 'package:finale/services/strava/strava.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/tools/workout_details.dart';
import 'package:flutter/material.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView();

  @override
  State<StatefulWidget> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticate() async {
    final success = await Strava().authenticate();

    if (success) {
      setState(() {});
    }
  }

  void _logout() {
    Preferences.clearStravaAuthData();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      'Strava Workouts',
      actions: [
        if (Preferences.hasStravaAuthData)
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ],
    ),
    body: Preferences.hasStravaAuthData
        ? EntityDisplay<AthleteActivity>(
            request: const StravaListActivitiesRequest(),
            displayImages: false,
            leadingWidgetBuilder: (item) => Icon(item.icon),
            trailingWidgetBuilder: (_) => const Icon(Icons.chevron_right),
            onTap: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutDetails(activity: item),
                ),
              );
            },
          )
        : Center(
            child: OutlinedButton(
              onPressed: _authenticate,
              child: const Row(
                mainAxisSize: .min,
                children: [
                  Icon(SocialMediaIcons.strava),
                  SizedBox(width: 8),
                  Text('Log in with Strava'),
                ],
              ),
            ),
          ),
  );
}
