import 'package:finale/services/acrcloud/acrcloud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:url_launcher/url_launcher.dart';

class ACRCloudDialogResult {
  final bool wasCancelled;
  final ACRCloudResponseMusicItem? track;

  const ACRCloudDialogResult([this.track]) : wasCancelled = false;

  const ACRCloudDialogResult.cancelled() : wasCancelled = true, track = null;
}

class ACRCloudDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ACRCloudDialogState();
}

class _ACRCloudDialogState extends State<ACRCloudDialog> {
  late final ACRCloudSession session;
  String? error;
  List<ACRCloudResponseMusicItem>? results;

  @override
  void initState() {
    super.initState();
    session = ACRCloud.startSession();

    session.result.then((result) {
      session.dispose();

      if (result == null) {
        if (!mounted) return;
        Navigator.pop(context, const ACRCloudDialogResult.cancelled());
        return;
      }

      final errorMessage = result.errorMessage;
      if (errorMessage != null) {
        setState(() {
          error = errorMessage;
        });
        return;
      }

      if (result.metadata != null && result.metadata!.music.isNotEmpty) {
        setState(() {
          results = result.metadata!.music;
        });
      } else {
        if (!mounted) return;
        Navigator.pop(context, const ACRCloudDialogResult());
      }
    });
  }

  @override
  Widget build(BuildContext context) => error != null
      ? _ErrorDialog(error!)
      : results != null
      ? _ResultsDialog(results!)
      : _ListeningDialog(session);
}

class _ListeningDialog extends StatelessWidget {
  final ACRCloudSession session;

  const _ListeningDialog(this.session);

  Widget _audioIndicator(BuildContext context) => StreamBuilder<double>(
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
            child: Container(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Listening...'),
    content: _audioIndicator(context),
    actions: [
      TextButton(onPressed: session.cancel, child: const Text('Cancel')),
    ],
  );
}

class _ResultsDialog extends StatelessWidget {
  final List<ACRCloudResponseMusicItem> results;

  const _ResultsDialog(this.results);

  Widget _resultsList() => SizedBox(
    width: double.maxFinite,
    child: ListView.builder(
      shrinkWrap: true,
      padding: .zero,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final track = results[index];
        return ListTile(
          contentPadding: .zero,
          title: Text(track.title),
          subtitle: Text('${track.artists.first.name}\n${track.album.name}'),
          isThreeLine: true,
          trailing: IconButton(
            icon: const Icon(Icons.info),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey
                : null,
            onPressed: () {
              launchUrl(
                .https('aha-music.com', track.acrId, {
                  'utm_source': 'finale',
                  'utm_medium': 'app',
                }),
              );
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
    title: const Text('Results'),
    content: _resultsList(),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, const ACRCloudDialogResult.cancelled());
        },
        child: const Text('Cancel'),
      ),
    ],
  );
}

class _ErrorDialog extends StatelessWidget {
  final String error;

  const _ErrorDialog(this.error);

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Error'),
    content: Text(error),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, const ACRCloudDialogResult.cancelled());
        },
        child: const Text('Close'),
      ),
    ],
  );
}
