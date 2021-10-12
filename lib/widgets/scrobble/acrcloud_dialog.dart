import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class ACRCloudDialogResult {
  bool wasCancelled;
  ACRCloudResponseMusicItem? track;

  ACRCloudDialogResult([this.track]) : wasCancelled = false;

  ACRCloudDialogResult.cancelled() : wasCancelled = true;
}

class ACRCloudDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ACRCloudDialogState();
}

class _ACRCloudDialogState extends State<ACRCloudDialog> {
  late ACRCloudSession session;
  List<ACRCloudResponseMusicItem>? results;

  @override
  void initState() {
    super.initState();
    session = ACRCloud.startSession();

    session.result.then((result) {
      session.dispose();

      if (result == null) {
        Navigator.pop(context, ACRCloudDialogResult.cancelled());
        return;
      }

      if (result.metadata != null && result.metadata!.music.isNotEmpty) {
        setState(() {
          results = result.metadata!.music;
        });
      } else {
        Navigator.pop(context, ACRCloudDialogResult());
      }
    });
  }

  Widget _buildResultsList(BuildContext context) => SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results!.length,
          itemBuilder: (BuildContext context, int index) {
            final track = results![index];
            return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(track.title),
                subtitle:
                    Text('${track.artists.first.name}\n${track.album.name}'),
                isThreeLine: true,
                trailing: IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () => launch(
                        'https://aha-music.com/${track.acrId}?utm_source=finale&utm_medium=app')),
                onTap: () =>
                    Navigator.pop(context, ACRCloudDialogResult(track)));
          }));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(results != null ? 'Results' : 'Listening...'),
      content: results != null ? _buildResultsList(context) : null,
      actions: [
        TextButton(
            child: const Text('Cancel'),
            onPressed: results != null
                ? () => Navigator.pop(context, ACRCloudDialogResult.cancelled())
                : session.cancel)
      ],
    );
  }
}
