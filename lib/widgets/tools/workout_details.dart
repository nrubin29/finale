import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/services/strava/activity.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:flutter/material.dart';

class WorkoutDetails extends StatelessWidget {
  final AthleteActivity activity;

  const WorkoutDetails({required this.activity});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: createAppBar(
            activity.name,
            subtitle: activity.localTimeRangeFormatted,
            bottom: TabBar(
              tabs: [
                const Tab(icon: Icon(Icons.queue_music)),
                Tab(icon: Icon(activity.icon)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              EntityDisplay<LRecentTracksResponseTrack>(
                request: GetRecentTracksRequest(Preferences().name!,
                    from:
                        activity.startDate.subtract(const Duration(minutes: 1)),
                    to: activity.endDate.add(const Duration(minutes: 1))),
                detailWidgetBuilder: (track) => TrackView(track: track),
              ),
              ListView(
                children: [
                  ListTile(
                    title: const Text('Elapsed Time'),
                    leading: const Icon(Icons.schedule),
                    trailing: Text(formatDuration(
                        Duration(seconds: activity.elapsedTime))),
                  ),
                  ListTile(
                    title: const Text('Moving Time'),
                    leading: const Icon(Icons.timer),
                    trailing: Text(
                        formatDuration(Duration(seconds: activity.movingTime))),
                  ),
                  if (activity.distance > 0)
                    ListTile(
                      title: const Text('Distance'),
                      leading: const Icon(Icons.map),
                      trailing:
                          Text(pluralize(activity.distance, 'mile')),
                    ),
                  if (activity.totalElevationGain > 0)
                    ListTile(
                      title: const Text('Elevation Gain'),
                      leading: const Icon(Icons.height),
                      trailing: Text('${activity.totalElevationGain} ft'),
                    ),
                  if (activity.averageSpeed > 0)
                    ListTile(
                      title: const Text('Average Speed'),
                      leading: const Icon(Icons.speed),
                      trailing: Text(
                          '${activity.averageSpeed.toStringAsFixed(1)} mph'),
                    ),
                  if (activity.averageHeartRate != null)
                    ListTile(
                      title: const Text('Average Heart Rate'),
                      leading: const Icon(Icons.favorite),
                      trailing: Text('${activity.averageHeartRate} bpm'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}
