import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/period_paged_request.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/functions.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/list_tile_username_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class _HIndexResult {
  final String username;
  final Period period;
  final EntityType entityType;
  final int hIndex;
  final Entity hEntity;
  final Entity? hPlusOneEntity;

  const _HIndexResult({
    required this.username,
    required this.period,
    required this.entityType,
    required this.hIndex,
    required this.hEntity,
    required this.hPlusOneEntity,
  });
}

class HIndexView extends StatefulWidget {
  const HIndexView();

  @override
  State<StatefulWidget> createState() => _HIndexViewState();
}

class _HIndexViewState extends State<HIndexView> {
  final _usernameTextController = TextEditingController();
  late Period _period;
  var _entityType = EntityType.artist;

  @override
  void initState() {
    super.initState();
    _period = Preferences.period.value;
  }

  Future<_HIndexResult?> _loadData() async {
    final username = _usernameTextController.text;
    final PeriodPagedRequest request = switch (_entityType) {
      EntityType.artist => GetTopArtistsRequest(username, _period),
      EntityType.album => GetTopAlbumsRequest(username, _period),
      EntityType.track => GetTopTracksRequest(username, _period),
      _ => throw StateError('Unsupported entity type'),
    };

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

    final hIndex =
        await upperBound(
          numItems,
          (index) async => index.compareTo(
            (await request.getData(1, index)).single.playCount,
          ),
        ) -
        1;
    final hEntity = (await request.getData(1, hIndex)).single;
    final hPlusOneEntity = (await request.getData(1, hIndex + 1)).firstOrNull;

    return _HIndexResult(
      username: username,
      period: _period,
      entityType: _entityType,
      hIndex: hIndex,
      hEntity: hEntity,
      hPlusOneEntity: hPlusOneEntity,
    );
  }

  Widget _entityListTile(Entity entity) => ListTile(
    title: Text(entity.displayTitle),
    subtitle: entity.displaySubtitle == null
        ? null
        : Text(entity.displaySubtitle!),
    trailing: entity.displayTrailing == null
        ? null
        : Text(entity.displayTrailing!),
    leading: EntityImage(entity: entity),
    onTap: () {
      pushLastfmEntityDetailView(context, entity);
    },
  );

  Widget _body(BuildContext context, _HIndexResult result) {
    final hIndex = numberFormat.format(result.hIndex);
    final hIndexOrdinal = formatOrdinal(result.hIndex);
    final hIndexPlusOne = numberFormat.format(result.hIndex + 1);
    final hIndexPlusOneOrdinal = formatOrdinal(result.hIndex + 1);
    final username = result.username == Preferences.name.value
        ? null
        : result.username;
    final entityName = result.entityType.displayName.toLowerCase();
    final period = result.period.formattedForSentence;

    String your, youve, youHavent, increase;
    String leadIn, explanation;

    if (username == null) {
      your = 'Your';
      youve = "you've";
      youHavent = "you haven't";
      increase =
          'Want to increase your h-index? The quickest way is to '
          'scrobble your $hIndexPlusOneOrdinal $entityName more:';
    } else {
      your = "$username's";
      youve = '$username has';
      youHavent = "they haven't";
      increase =
          'Does $username want to increase their h-index? The quickest '
          'way is for them to scrobble their $hIndexPlusOneOrdinal $entityName '
          'more:';
    }

    if (result.period == Period.overall) {
      leadIn = '$your h-index for ${entityName}s is:';
      explanation =
          "This means that $youve scrobbled $hIndex "
          "${entityName}s at least $hIndex times, but $youHavent scrobbled "
          '$hIndexPlusOne ${entityName}s at least $hIndexPlusOne times.';
    } else {
      leadIn = '$your h-index for ${entityName}s $period is:';
      explanation =
          "This means that $period, $youve scrobbled $hIndex "
          "${entityName}s at least $hIndex times, but $youHavent scrobbled "
          '$hIndexPlusOne ${entityName}s at least $hIndexPlusOne times.';
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        spacing: 8,
        children: [
          Text(leadIn),
          Text(hIndex, style: Theme.of(context).textTheme.displayLarge),
          Text('$explanation $your $hIndexOrdinal $entityName is:'),
          _entityListTile(result.hEntity),
          if (result.hPlusOneEntity != null) ...[
            Text(increase),
            _entityListTile(result.hPlusOneEntity!),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'h-index'),
    body: CollapsibleFormView<_HIndexResult>(
      submitButtonText: 'Calculate',
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
              DropdownMenuItem(
                value: EntityType.artist,
                child: Text('Artists'),
              ),
              DropdownMenuItem(value: EntityType.album, child: Text('Albums')),
              DropdownMenuItem(value: EntityType.track, child: Text('Tracks')),
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
      bodyBuilder: _body,
    ),
  );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}
