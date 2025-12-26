import 'package:finale/services/lastfm/lastfm_cookie.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:flutter/material.dart';

class ScrobbleEditorView extends StatefulWidget {
  final List<LRecentTracksResponseTrack> tracks;
  final bool isSingleScrobble;

  const ScrobbleEditorView({required this.tracks}) : isSingleScrobble = false;

  ScrobbleEditorView.forSingleScrobble({
    required LRecentTracksResponseTrack track,
  }) : tracks = [track],
       isSingleScrobble = true;

  @override
  State<ScrobbleEditorView> createState() => _ScrobbleEditorViewState();
}

class _ScrobbleEditorViewState extends State<ScrobbleEditorView> {
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;

  late final String? _initialTitle;
  late final String? _initialArtist;
  late final String? _initialAlbum;

  @override
  void initState() {
    super.initState();

    _initialTitle = _initialValue((track) => track.name);
    _titleController = TextEditingController(text: _initialTitle);

    _initialArtist = _initialValue((track) => track.artistName);
    _artistController = TextEditingController(text: _initialArtist);

    _initialAlbum = _initialValue((track) => track.albumName);
    _albumController = TextEditingController(text: _initialAlbum);
  }

  String? _initialValue(
    String Function(LRecentTracksResponseTrack track) getter,
  ) => widget.tracks.map(getter).toSet().length == 1
      ? getter(widget.tracks.first)
      : null;

  void _submit() async {
    final result = ScrobbleEditRequest(
      newTitle: _finalValue(_titleController, _initialTitle),
      newArtist: _finalValue(_artistController, _initialArtist),
      newAlbum: _finalValue(_albumController, _initialAlbum),
    );

    if (!result.isValid) {
      showMessageDialog(
        context,
        title: 'Error',
        content: 'At least one field must be modified.',
      );
      return;
    }

    if (!widget.isSingleScrobble) {
      final confirmation = await showConfirmationDialog(
        context,
        content:
            'Are you sure that you want to apply the following edits to '
            '${pluralize(widget.tracks.length)}?\n\n'
            '${result.toSentence()}',
      );
      if (!confirmation) return;
      if (!mounted) return;
    }

    Navigator.pop(context, result);
  }

  String? _finalValue(TextEditingController controller, String? initialValue) {
    final value = controller.text;
    if (value.isEmpty || value == initialValue) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(
      context,
      widget.isSingleScrobble
          ? 'Edit scrobble'
          : 'Edit ${pluralize(widget.tracks.length)}',
      actions: [IconButton(onPressed: _submit, icon: const Icon(Icons.send))],
    ),
    body: Form(
      child: Column(
        children: [
          Padding(
            padding: const .symmetric(vertical: 8, horizontal: 16),
            child: Text(
              [
                "If a field is left blank, its value won't be updated.",
                if (!widget.isSingleScrobble)
                  'You will be able to confirm your edits before they are '
                      'applied.',
              ].join(' '),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: TextFormField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: 'Artist'),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: TextFormField(
              controller: _albumController,
              decoration: const InputDecoration(labelText: 'Album'),
            ),
          ),
        ],
      ),
    ),
  );
}
