import 'dart:async';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/social_media_icons_icons.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/date_time_field.dart';
import 'package:finale/widgets/base/header_list_tile.dart';
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
  final _albumArtistController = TextEditingController();

  var _useCustomTimestamp = false;
  DateTime? _customTimestamp;

  var _isLoading = false;

  late StreamSubscription _showAlbumArtistFieldSubscription;
  StreamSubscription? _appleMusicChangeSubscription;
  late bool _showAlbumArtistField;
  late bool _isAppleMusicEnabled;

  @override
  void initState() {
    super.initState();
    _trackController.text = widget.track?.name ?? '';
    _artistController.text = widget.track?.artistName ?? '';
    _albumController.text = widget.track?.albumName ?? '';
    _albumArtistController.text = widget.track?.albumArtist ?? '';

    _showAlbumArtistFieldSubscription = Preferences.showAlbumArtistField.changes
        .listen((value) {
          setState(() {
            _showAlbumArtistField = value;
          });
        });

    _showAlbumArtistField = Preferences.showAlbumArtistField.value;

    if (!widget.isModal) {
      _appleMusicChangeSubscription = Preferences.appleMusicEnabled.changes
          .listen((_) {
            setState(() {
              _isAppleMusicEnabled = Preferences.appleMusicEnabled.value;
            });
          });

      _isAppleMusicEnabled = Preferences.appleMusicEnabled.value;
    }
  }

  String? _required(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Required';
    }

    return null;
  }

  Future<void> _scrobble(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final response = await Lastfm.scrobble(
      [
        BasicConcreteTrack(
          _trackController.text,
          _artistController.text,
          _albumController.text,
          _showAlbumArtistField && _albumArtistController.text.isNotEmpty
              ? _albumArtistController.text
              : null,
        ),
      ],
      [_useCustomTimestamp ? _customTimestamp! : DateTime.now()],
    );

    setState(() {
      _isLoading = false;
    });

    if (widget.isModal) {
      if (!context.mounted) return;
      Navigator.pop(context, response.ignored == 0);
      return;
    }

    if (!context.mounted) return;
    if (response.ignored == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Scrobbled successfully!')));
      _trackController.text = '';
      _artistController.text = '';
      _albumController.text = '';

      // Ask for a review
      if (await InAppReview.instance.isAvailable()) {
        InAppReview.instance.requestReview();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while scrobbling')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        context,
        'Scrobble',
        actions: [
          Builder(
            builder:
                (context) =>
                    _isLoading
                        ? const AppBarLoadingIndicator()
                        : IconButton(
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
                  const SizedBox(height: 8),
                ],
                TitledBox(
                  title: 'Sources',
                  actions: [
                    if (Platform.isIOS && _isAppleMusicEnabled)
                      ButtonAction('Apple Music', SocialMediaIcons.apple, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppleMusicScrobbleView(),
                          ),
                        );
                      }),
                    ButtonAction('Friend', Icons.people, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FriendScrobbleView(),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                const HeaderListTile('Manual'),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _trackController,
                  decoration: const InputDecoration(labelText: 'Song *'),
                  validator: _required,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(labelText: 'Artist *'),
                  validator: _required,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _albumController,
                  decoration: const InputDecoration(labelText: 'Album'),
                ),
              ),
              if (_showAlbumArtistField)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: _albumArtistController,
                    decoration: const InputDecoration(
                      labelText: 'Album Artist',
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SwitchListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Custom timestamp'),
                  value: _useCustomTimestamp,
                  onChanged: (value) {
                    setState(() {
                      _useCustomTimestamp = value;

                      if (_useCustomTimestamp) {
                        _customTimestamp = DateTime.now();
                      }
                    });
                  },
                ),
              ),
              Visibility(
                visible: _useCustomTimestamp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DateTimeField(
                    initialValue: _customTimestamp,
                    onChanged: (dateTime) {
                      setState(() {
                        _customTimestamp = dateTime;
                      });
                    },
                  ),
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
    _showAlbumArtistFieldSubscription.cancel();
    _appleMusicChangeSubscription?.cancel();
    _trackController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _albumArtistController.dispose();
  }
}
