import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/util/util.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/titled_box.dart';
import 'package:finale/widgets/scrobble/apple_music_scrobble_view.dart';
import 'package:finale/widgets/scrobble/friend_scrobble_view.dart';
import 'package:finale/widgets/scrobble/music_recognition_component.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:universal_io/io.dart';

class ScrobbleView extends StatefulWidget {
  final Track? track;
  final bool isModal;

  const ScrobbleView({this.track, this.isModal = false});

  @override
  State<StatefulWidget> createState() => _ScrobbleViewState();
}

class _ScrobbleViewState extends State<ScrobbleView> {
  final _formKey = GlobalKey<FormState>();

  final _trackController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();

  var _useCustomTimestamp = false;
  DateTime? _customTimestamp;

  @override
  void initState() {
    super.initState();
    _trackController.text = widget.track?.name ?? '';
    _artistController.text = widget.track?.artistName ?? '';
    _albumController.text = widget.track?.albumName ?? '';
  }

  String? _required(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Required';
    }

    return null;
  }

  Future<void> _scrobble(BuildContext context) async {
    final response = await Lastfm.scrobble([
      BasicConcreteTrack(
          _trackController.text, _artistController.text, _albumController.text)
    ], [
      _useCustomTimestamp ? _customTimestamp! : DateTime.now()
    ]);

    if (widget.isModal) {
      Navigator.pop(context, response.ignored == 0);
      return;
    }

    if (response.ignored == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scrobbled successfully!')));
      _trackController.text = '';
      _artistController.text = '';
      _albumController.text = '';

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while scrobbling')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        'Scrobble',
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(scrobbleIcon),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _scrobble(context);
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10),
            physics: const ScrollPhysics(),
            children: [
              if (!widget.isModal) ...[
                if (isMobile) ...[
                  MusicRecognitionComponent(
                    onTrackRecognized: (track) {
                      setState(() {
                        _trackController.text = track.title;
                        _albumController.text = track.album.name;
                        _artistController.text = track.artists.first.name;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                TitledBox(
                  title: 'Sources',
                  actions: [
                    if (Platform.isIOS)
                      ButtonAction('Apple Music', SocialMediaIcons.apple, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AppleMusicScrobbleView()),
                        );
                      }),
                    ButtonAction('Friend', Icons.people, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FriendScrobbleView()));
                    }),
                  ],
                ),
              ],
              TextFormField(
                controller: _trackController,
                decoration: const InputDecoration(labelText: 'Song *'),
                validator: _required,
              ),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist *'),
                validator: _required,
              ),
              TextFormField(
                controller: _albumController,
                decoration: const InputDecoration(labelText: 'Album'),
              ),
              SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('Custom timestamp'),
                value: _useCustomTimestamp,
                onChanged: (value) {
                  setState(
                    () {
                      _useCustomTimestamp = value;

                      if (_useCustomTimestamp) {
                        _customTimestamp = DateTime.now();
                      }
                    },
                  );
                },
              ),
              Visibility(
                visible: _useCustomTimestamp,
                child: DateTimeField(
                  initialValue: _customTimestamp,
                  onChanged: (dateTime) {
                    setState(() {
                      _customTimestamp = dateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _trackController.dispose();
    _artistController.dispose();
    _albumController.dispose();
  }
}
