import 'package:finale/components/acrcloud_dialog_component.dart';
import 'package:finale/views/listen_continuously_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicRecognitionComponent extends StatefulWidget {
  final ValueChanged<ACRCloudResponseMusicItem> onTrackRecognized;

  MusicRecognitionComponent({@required this.onTrackRecognized});

  @override
  _MusicRecognitionComponentState createState() =>
      _MusicRecognitionComponentState();
}

class _MusicRecognitionComponentState extends State<MusicRecognitionComponent> {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Music Recognition",
                  style: Theme.of(context).textTheme.bodyText1),
              TextButton(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Powered by ',
                        style: Theme.of(context).textTheme.caption),
                    Image.asset('assets/images/acrcloud.png', height: 20)
                  ]),
                  onPressed: () {
                    launch('https://acrcloud.com');
                  })
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                child: Text('Listen once'),
                onPressed: () async {
                  final result = await showDialog<ACRCloudDialogResult>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ACRCloudDialogComponent());

                  if (result?.wasCancelled ?? true) return;

                  if (result.track != null) {
                    widget.onTrackRecognized(result.track);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not recognize song')));
                  }
                },
              ),
              OutlinedButton(
                child: Text('Listen continuously'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListenContinuouslyView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ]),
      );
}
