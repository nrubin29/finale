import 'package:finale/widgets/base/app_bar.dart';
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
            ListTile(
              title: const Text('Collage Generator'),
              leading: const Icon(Icons.grid_view),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CollageView()),
                );
              },
            ),
            ListTile(
              title: const Text('Strava Workouts'),
              leading: const Icon(Icons.run_circle),
              trailing: const Icon(Icons.chevron_right),
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
