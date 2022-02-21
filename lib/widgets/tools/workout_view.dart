import 'package:finale/services/strava/activity.dart';
import 'package:finale/services/strava/strava.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/tools/workout_details.dart';
import 'package:flutter/material.dart';

class WorkoutView extends StatefulWidget {
  const WorkoutView();

  @override
  State<StatefulWidget> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  List<AthleteActivity>? _activities;

  Future<void> _authenticate() async {
    await Strava().authenticate();

    var activities = await const StravaListActivitiesRequest().doRequest(20, 1);
    setState(() {
      _activities = activities;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar('Strava Workouts'),
        body: ListView(
          children: [
            TextButton(
              onPressed: _authenticate,
              child: const Text('Log in with Strava'),
            ),
            if (_activities != null)
              for (final activity in _activities!)
                ListTile(
                  title: Text(activity.name),
                  subtitle: Text(dateTimeFormat.format(activity.startDateLocal) +
                      ' - ' +
                      timeFormat.format(activity.endDateLocal)),
                  leading: const Icon(Icons.run_circle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => WorkoutDetails(activity: activity)),
                    );
                  },
                ),
          ],
        ),
      );
}
