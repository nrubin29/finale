import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class ACRCloudDialogResult {
  final bool wasCancelled;
  final ACRCloudResponseMusicItem? track;

  const ACRCloudDialogResult([this.track]) : wasCancelled = false;

  const ACRCloudDialogResult.cancelled()
      : wasCancelled = true,
        track = null;
}

class ACRCloudDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ACRCloudDialogState();
}

class _ACRCloudDialogState extends State<ACRCloudDialog> {
  late final ACRCloudSession session;
  List<ACRCloudResponseMusicItem>? results;

  @override
  void initState() {
    super.initState();
    session = ACRCloud.startSession();

    session.result.then((result) {
      session.dispose();

      if (result == null) {
        Navigator.pop(context, const ACRCloudDialogResult.cancelled());
        return;
      }

      if (result.metadata != null && result.metadata!.music.isNotEmpty) {
        setState(() {
          results = result.metadata!.music;
        });
      } else {
        Navigator.pop(context, const ACRCloudDialogResult());
      }
    });
  }

  Widget _audioIndicator() => StreamBuilder<double>(
        stream: session.volumeStream,
        initialData: 0.0,
        builder: (_, snapshot) => SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: ClipOval(
              child: SizedBox(
                width: 90 * snapshot.data! + 10,
                height: 90 * snapshot.data! + 10,
                child: Container(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      );

  Widget _resultsList() => SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results!.length,
          itemBuilder: (context, index) {
            final track = results![index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(track.title),
              subtitle:
                  Text('${track.artists.first.name}\n${track.album.name}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  launchUrl(Uri.https('aha-music.com', track.acrId,
                      {'utm_source': 'finale', 'utm_medium': 'app'}));
                },
              ),
              onTap: () {
                Navigator.pop(context, ACRCloudDialogResult(track));
              },
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(results != null ? 'Results' : 'Listening...'),
        content: results != null ? _resultsList() : _audioIndicator(),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: results != null
                ? () {
                    Navigator.pop(
                        context, const ACRCloudDialogResult.cancelled());
                  }
                : session.cancel,
          )
        ],
      );
}
