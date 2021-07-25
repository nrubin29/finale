import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/entity_display_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class CollageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CollageViewState();
}

class _CollageViewState extends State<CollageView> {
  var _isSettingsExpanded = true;
  final _usernameTextController =
      TextEditingController(text: Preferences().name ?? 'Enter username');
  var _gridSize = 5;
  var _period = Period.overall;
  var _includeBranding = true;

  var _isDoingRequest = false;
  Uint8List? _image;
  final _screenshotController = ScreenshotController();

  Future<void> _doRequest() async {
    setState(() {
      _isDoingRequest = true;
      _isSettingsExpanded = false;
      _image = null;
    });

    final items = [
      for (var item
          in await GetTopAlbumsRequest(_usernameTextController.text, _period)
              .doRequest(_gridSize * _gridSize, 1))
        _LAlbumForCollage(item),
    ];

    final image = await _screenshotController.captureFromWidget(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EntityDisplayComponent(
              items: items,
              displayType: DisplayType.grid,
              showGridTileGradient: false,
              gridTileSize: MediaQuery.of(context).size.width / _gridSize,
            ),
            if (_includeBranding) ...[
              const SizedBox(height: 5),
              Row(children: [
                const SizedBox(width: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset('assets/images/icon.png', width: 30),
                ),
                const SizedBox(width: 5),
                const Text(
                  'finale.app',
                  style: TextStyle(color: Colors.black),
                ),
              ]),
              const SizedBox(height: 5),
            ],
          ],
        ),
      ),
      pixelRatio: 3,
      context: context,
    );

    setState(() {
      _image = image;
      _isDoingRequest = false;
    });
  }

  Widget get _form => ExpansionPanelList(
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (_, __) {
            setState(() {
              _isSettingsExpanded = !_isSettingsExpanded;
            });
          },
          children: [
            ExpansionPanel(
                headerBuilder: (_, __) =>
                    const ListTile(title: Text('Settings')),
                canTapOnHeader: true,
                isExpanded: _isSettingsExpanded,
                body: Column(
                  children: [
                    ListTile(
                      title: const Text('Username'),
                      trailing: IntrinsicWidth(
                          child:
                              TextField(controller: _usernameTextController)),
                    ),
                    ListTile(
                      title: const Text('Type'),
                      trailing: DropdownButton<EntityType>(
                        value: EntityType.album,
                        items: [
                          DropdownMenuItem(
                            value: EntityType.album,
                            child: Text('Top Albums'),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('Period'),
                      trailing: DropdownButton<Period>(
                        value: _period,
                        items: [
                          for (final period in Period.values)
                            DropdownMenuItem(
                              value: period,
                              child: Text(period.display),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _period = value;
                            });
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Grid size'),
                      trailing: DropdownButton<int>(
                        value: _gridSize,
                        items: [
                          for (var i = 3; i <= 10; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text('${i}x$i'),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _gridSize = value;
                            });
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Include Finale branding'),
                      trailing: Switch(
                        value: _includeBranding,
                        onChanged: (value) {
                          if (value != _includeBranding) {
                            setState(() {
                              _includeBranding = value;
                            });
                          }
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: _doRequest,
                      child: const Text('Generate'),
                    ),
                  ],
                )),
          ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar('Collage Generator'),
        body: Center(
          child: _isDoingRequest
              ? const CircularProgressIndicator()
              : ListView(children: [
                  _form,
                  if (_image != null) ...[
                    Image.memory(_image!),
                    SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                          'If any images failed to load, try generating the '
                          "collage again. If images still don't load, Last.fm "
                          "most likely doesn't have an image for that album."),
                    ),
                    if (isMobile)
                      TextButton(
                        onPressed: () async {
                          final tempDir = (await getTemporaryDirectory()).path;
                          final tempFile = File('$tempDir/collage.png');
                          await tempFile.writeAsBytes(_image!);
                          await GallerySaver.saveImage(tempFile.path);
                          await tempFile.delete();
                        },
                        child: const Text('Save to camera roll'),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                            'Saving collages is currently not supported on '
                            'web.'),
                      ),
                  ],
                ]),
        ),
      );

  @override
  void dispose() {
    _usernameTextController.dispose();
    super.dispose();
  }
}

class _LAlbumForCollage extends BasicAlbum {
  final BasicAlbum _album;

  _LAlbumForCollage(this._album);

  @override
  BasicArtist get artist => ConcreteBasicArtist('');

  @override
  String get name => '';

  @override
  String? get url => _album.url;

  @override
  FutureOr<ImageId?> get imageId => _album.imageId;
}
