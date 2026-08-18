import 'package:finale/services/acrcloud/acrcloud.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

sealed class ACRCloudDialogResult {
  const new();
}

class ACRCloudDialogResultTrack extends ACRCloudDialogResult {
  final ACRCloudResponseMusicItem track;

  new({required this.track});
}

class ACRCloudDialogResultCancelled extends ACRCloudDialogResult {
  const new();
}

class ACRCloudDialogResultNoMatch extends ACRCloudDialogResult {
  const new();
}

class ACRCloudDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ACRCloudDialogState();
}

class _ACRCloudDialogState extends State<ACRCloudDialog> {
  ACRCloudSession? session;
  String? error;
  List<ACRCloudResponseMusicItem>? results;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  void _startSession() async {
    final session = await ACRCloud.instance.startSession();
    setState(() {
      this.session = session;
    });

    final result = await session.result;
    if (!mounted) return;

    switch (result) {
      case ACRCloudRecognized(:final music):
        setState(() {
          results = music;
        });
      case ACRCloudNoMatch():
        Navigator.pop(context, const ACRCloudDialogResultNoMatch());
      case ACRCloudCancelled():
        Navigator.pop(context, const ACRCloudDialogResultCancelled());
        return;
      case ACRCloudFailure():
        setState(() {
          error = result.errorMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) => error != null
      ? _ErrorDialog(error!)
      : results != null
      ? _ResultsDialog(results!)
      : session != null
      ? _ListeningDialog(session!)
      : const SizedBox();
}

class _ListeningDialog extends StatelessWidget {
  final ACRCloudSession session;

  const _ListeningDialog(this.session);

  Widget _audioIndicator(BuildContext context) => StreamBuilder<double>(
    stream: session.volume,
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
          subtitle: track.album == null
              ? Text(track.artists.first.name)
              : Text('${track.artists.first.name}\n${track.album!.name}'),
          isThreeLine: track.album != null,
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
            Navigator.pop(context, ACRCloudDialogResultTrack(track: track));
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
          Navigator.pop(context, const ACRCloudDialogResultCancelled());
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
          Navigator.pop(context, const ACRCloudDialogResultCancelled());
        },
        child: const Text('Close'),
      ),
    ],
  );
}
