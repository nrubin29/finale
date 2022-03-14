import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:finale/widgets/entity/lastfm/album_view.dart';
import 'package:finale/widgets/entity/lastfm/artist_view.dart';
import 'package:finale/widgets/entity/lastfm/track_view.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:flutter/material.dart';

class LuckyView extends StatefulWidget {
  const LuckyView();

  @override
  _LuckyViewState createState() => _LuckyViewState();
}

class _LuckyViewState extends State<LuckyView> {
  static final _random = Random();

  final _formKey = GlobalKey<CollapsibleFormViewState>();
  late final TextEditingController _usernameTextController;
  late Period _period;
  var _entityType = EntityType.track;

  Entity? _entity;

  @override
  void initState() {
    super.initState();
    _usernameTextController = TextEditingController(text: Preferences().name);
    _period = Preferences().period;
  }

  Future<bool> _loadData() async {
    setState(() {
      _entity = null;
    });

    final username = _usernameTextController.text;
    final request = GetRecentTracksRequest(username,
        from: _period.relativeStart, to: _period.end);

    int numItems;
    try {
      numItems = await request.getNumItems();
    } on LException catch (e) {
      if (e.message == 'no such page') {
        numItems = 0;
      } else {
        showLExceptionDialog(context, error: e, username: username);
        return false;
      }
    }

    if (numItems == 0) {
      showNoEntityTypePeriodDialog(context,
          entityType: _entityType, username: username);
      return false;
    }

    final randomIndex = _random.nextInt(numItems) + 1;
    final response = await request.getData(1, randomIndex);

    if (response.isNotEmpty) {
      final responseEntity = response.single;
      Entity entity;

      if (_entityType == EntityType.album) {
        entity = await Lastfm.getAlbum(ConcreteBasicAlbum(
            responseEntity.albumName, responseEntity.artist));
      } else if (_entityType == EntityType.artist) {
        entity = await Lastfm.getArtist(responseEntity.artist);
      } else if (_entityType == EntityType.track) {
        entity = await Lastfm.getTrack(responseEntity);
      } else {
        throw Exception('This will never happen.');
      }

      setState(() {
        _entity = entity;
      });
    }

    return true;
  }

  String? _validator(String? value) =>
      value == null || value.isEmpty ? 'This field is required.' : null;

  void _showDetails() {
    Widget detailWidget;

    if (_entity! is Track) {
      detailWidget = TrackView(track: _entity as Track);
    } else if (_entity is BasicAlbum) {
      detailWidget = AlbumView(album: _entity as BasicAlbum);
    } else if (_entity is BasicArtist) {
      detailWidget = ArtistView(artist: _entity as BasicArtist);
    } else {
      throw Exception('This will never happen.');
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => detailWidget));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar("I'm Feeling Lucky"),
        body: CollapsibleFormView(
          key: _formKey,
          submitButtonText: 'Roll the Dice',
          onFormSubmit: _loadData,
          formWidgets: [
            ListTileTextField(
              title: 'Username',
              controller: _usernameTextController,
              validator: _validator,
            ),
            ListTile(
              title: const Text('Period'),
              trailing: PeriodDropdownButton(
                periodChanged: (period) {
                  _period = period;
                },
              ),
            ),
            ListTile(
              title: const Text('Type'),
              trailing: DropdownButton<EntityType>(
                value: _entityType,
                items: const [
                  DropdownMenuItem(
                    value: EntityType.track,
                    child: Text('Tracks'),
                  ),
                  DropdownMenuItem(
                    value: EntityType.album,
                    child: Text('Albums'),
                  ),
                  DropdownMenuItem(
                    value: EntityType.artist,
                    child: Text('Artists'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _entityType = value;
                    });
                  }
                },
              ),
            ),
          ],
          body: _entity != null
              ? Column(
                  children: [
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.height / 2),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: EntityImage(
                          entity: _entity!,
                          quality: ImageQuality.high,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _showDetails,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _entity!.displayTitle,
                                  style: const TextStyle(fontSize: 22),
                                  textAlign: TextAlign.center,
                                ),
                                if (_entity!.displaySubtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _entity!.displaySubtitle!,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                                if (_entity!.displayTrailing != null) ...[
                                  const SizedBox(height: 4),
                                  Text(_entity!.displayTrailing!),
                                ],
                              ],
                            ),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: SafeArea(
                                minimum: EdgeInsets.only(right: 16),
                                child: Icon(Icons.chevron_right),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _formKey.currentState?.onFormSubmit,
                      child: const Text('Choose Another'),
                    ),
                  ],
                )
              : null,
        ),
      );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}
