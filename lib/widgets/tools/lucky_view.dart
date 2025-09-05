import 'dart:math';

import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/functions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/list_tile_username_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class LuckyView extends StatefulWidget {
  const LuckyView();

  @override
  State<StatefulWidget> createState() => _LuckyViewState();
}

class _LuckyViewState extends State<LuckyView> {
  static final _random = Random();

  final _formKey = GlobalKey<CollapsibleFormViewState>();
  final _usernameTextController = TextEditingController();
  late Period _period;
  var _entityType = EntityType.track;

  @override
  void initState() {
    super.initState();
    _period = Preferences.period.value;
  }

  Future<Entity?> _loadData() async {
    final username = _usernameTextController.text;
    final request = GetRecentTracksRequest.forPeriod(username, _period);

    int numItems;
    try {
      numItems = await request.getNumItems();
    } on Exception catch (e, st) {
      if (e is LException && e.message == 'no such page') {
        numItems = 0;
      } else {
        if (!mounted) return null;
        showExceptionDialog(
          context,
          error: e,
          stackTrace: st,
          detailObject: username,
        );
        return null;
      }
    }

    if (numItems == 0) {
      if (!mounted) return null;
      showNoEntityTypePeriodDialog(
        context,
        entityType: _entityType,
        username: username,
      );
      return null;
    }

    final randomIndex = _random.nextInt(numItems) + 1;
    final response = await request.getData(1, randomIndex);

    if (response.isNotEmpty) {
      final responseEntity = response.single;
      Entity entity;

      if (_entityType == EntityType.album) {
        entity = await Lastfm.getAlbum(
          ConcreteBasicAlbum(responseEntity.albumName, responseEntity.artist),
        );
      } else if (_entityType == EntityType.artist) {
        entity = await Lastfm.getArtist(responseEntity.artist);
      } else if (_entityType == EntityType.track) {
        entity = await Lastfm.getTrack(responseEntity);
      } else {
        throw Exception('This will never happen.');
      }

      return entity;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, "I'm Feeling Lucky"),
    body: CollapsibleFormView<Entity>(
      key: _formKey,
      submitButtonText: 'Roll the Dice',
      onFormSubmit: _loadData,
      formWidgetsBuilder: (_) => [
        ListTileUsernameField(controller: _usernameTextController),
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
              DropdownMenuItem(value: EntityType.track, child: Text('Tracks')),
              DropdownMenuItem(value: EntityType.album, child: Text('Albums')),
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
      bodyBuilder: (context, entity) => Column(
        children: [
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.height / 2,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: EntityImage(entity: entity, quality: ImageQuality.high),
            ),
          ),
          InkWell(
            onTap: () {
              pushLastfmEntityDetailView(context, entity);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        entity.displayTitle,
                        style: const TextStyle(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      if (entity.displaySubtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entity.displaySubtitle!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                      if (entity.displayTrailing != null) ...[
                        const SizedBox(height: 4),
                        Text(entity.displayTrailing!),
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
      ),
    ),
  );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}
