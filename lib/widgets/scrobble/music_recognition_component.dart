import 'dart:async';

import 'package:finale/env.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/quick_actions_manager.dart';
import 'package:finale/widgets/base/titled_box.dart';
import 'package:finale/widgets/scrobble/acrcloud_dialog.dart';
import 'package:finale/widgets/scrobble/listen_continuously_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicRecognitionComponent extends StatefulWidget {
  final ValueChanged<ACRCloudResponseMusicItem> onTrackRecognized;

  MusicRecognitionComponent({required this.onTrackRecognized})
      : assert(isMobile);

  @override
  _MusicRecognitionComponentState createState() =>
      _MusicRecognitionComponentState();
}

class _MusicRecognitionComponentState extends State<MusicRecognitionComponent> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _subscription =
        QuickActionsManager().quickActionStream.listen((action) async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (action.type == QuickActionType.scrobbleOnce) {
        _scrobbleOnce();
      } else if (action.type == QuickActionType.scrobbleContinuously) {
        _scrobbleContinuously();
      }
    });
  }

  Future<void> _setUp() async {
    if (!ACRCloud.isSetUp) {
      await ACRCloud.setUp(const ACRCloudConfig(
          acrCloudAccessKey, acrCloudAccessSecret, acrCloudHost));
    }
  }

  Future<void> _scrobbleOnce() async {
    await _setUp();
    final result = await showDialog<ACRCloudDialogResult>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ACRCloudDialog());

    if (result?.wasCancelled ?? true) return;

    if (result!.track != null) {
      widget.onTrackRecognized(result.track!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not recognize song')));
    }
  }

  Future<void> _scrobbleContinuously() async {
    await _setUp();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListenContinuouslyView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TitledBox(
        title: 'Music Recognition',
        trailing: TextButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Powered by ', style: Theme.of(context).textTheme.caption),
              Image.asset('assets/images/acrcloud.png', height: 20)
            ],
          ),
          onPressed: () {
            launch('https://acrcloud.com');
          },
        ),
        actions: [
          ButtonAction('Once', Icons.mic, _scrobbleOnce),
          ButtonAction(
              'Continuously', Icons.all_inclusive, _scrobbleContinuously),
        ],
      );

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
