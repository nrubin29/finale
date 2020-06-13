import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/acrcloud_response.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class ACRCloudDialogResult {
  bool wasCancelled;
  ACRCloudResponseMusicItem track;

  ACRCloudDialogResult({this.wasCancelled = false, this.track});
}

class ACRCloudDialogComponent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ACRCloudDialogComponentState();
}

class _ACRCloudDialogComponentState extends State<ACRCloudDialogComponent> {
  ACRCloudSession session;
  List<ACRCloudResponseMusicItem> results;

  @override
  void initState() {
    super.initState();
    session = ACRCloud.startSession();

    session.result.then((result) {
      session.dispose();

      if (result == null) {
        Navigator.pop(context, ACRCloudDialogResult(wasCancelled: true));
        return;
      }

      if (result.metadata?.music?.isNotEmpty ?? false) {
        setState(() {
          results = result.metadata.music;
        });
      } else {
        Navigator.pop(context, ACRCloudDialogResult(track: null));
      }
    });
  }

  Widget _buildResultsList(BuildContext context) => Container(
      width: double.maxFinite,
      child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            final track = results[index];
            return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(track.title),
                subtitle:
                    Text('${track.artists.first.name}\n${track.album.name}'),
                isThreeLine: true,
                trailing: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () => launch(
                        'https://aha-music.com/${track.acrId}?utm_source=finale&utm_medium=app')),
                onTap: () =>
                    Navigator.pop(context, ACRCloudDialogResult(track: track)));
          }));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(results != null ? 'Results' : 'Listening...'),
      content: results != null ? _buildResultsList(context) : null,
      actions: [
        FlatButton(
            child: Text('Cancel'),
            onPressed: results != null
                ? () => Navigator.pop(
                    context, ACRCloudDialogResult(wasCancelled: true))
                : session.cancel)
      ],
    );
  }
}
