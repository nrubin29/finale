import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:finale/components/app_bar_component.dart';
import 'package:finale/components/entity_display_component.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/util.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CollageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CollageViewState();
}

class _CollageViewState extends State<CollageView> {
  var _isSettingsExpanded = true;
  final _usernameTextController =
      TextEditingController(text: Preferences().name ?? 'Enter username');
  var _type = EntityType.album;
  var _period = Period.overall;
  var _gridSize = 5;
  var _includeText = true;
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

    PagedRequest<Entity> request;

    if (_type == EntityType.album) {
      request = GetTopAlbumsRequest(_usernameTextController.text, _period);
    } else if (_type == EntityType.artist) {
      request = GetTopArtistsRequest(_usernameTextController.text, _period);
    } else {
      throw Exception('$_type is not supported for collages.');
    }

    final items = await request.doRequest(_gridSize * _gridSize, 1);

    final gridTileSize = MediaQuery.of(context).size.width / _gridSize;
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
              showGridTileGradient: _includeText,
              gridTileSize: gridTileSize,
              fontSize: _includeText ? gridTileSize / 15 : 0,
              gridTileTextPadding: gridTileSize / 15,
            ),
            if (_includeBranding)
              Padding(
                padding: const EdgeInsets.all(3),
                child: Row(children: [
                  appIcon(size: gridTileSize / 8),
                  SizedBox(width: gridTileSize / 24),
                  Text(
                    'Created with Finale for Last.fm',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'https://finale.app',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: gridTileSize / 12,
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
      delay: const Duration(seconds: 5),
      pixelRatio: 3,
      context: context,
    );

    setState(() {
      _image = image;
      _isDoingRequest = false;
    });
  }

  Future<File> get _imageFile async {
    final tempDir = (await getTemporaryDirectory()).path;
    final tempFile = File('$tempDir/collage.png');
    await tempFile.writeAsBytes(_image!);
    return tempFile;
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
                        value: _type,
                        items: [
                          DropdownMenuItem(
                            value: EntityType.album,
                            child: Text('Top Albums'),
                          ),
                          DropdownMenuItem(
                            value: EntityType.artist,
                            child: Text('Top Artists'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _type = value;
                            });
                          }
                        },
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
                      title: const Text('Include text'),
                      trailing: Switch(
                        value: _includeText,
                        onChanged: (value) {
                          if (value != _includeText) {
                            setState(() {
                              _includeText = value;
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
                    OutlinedButton(
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
                          'If any images failed to load, wait a few seconds '
                          'and try generating the collage again. If an image '
                          "still doesn't load, Last.fm most likely doesn't "
                          'have an image for that item.'),
                    ),
                    if (isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final tempFile = await _imageFile;
                              await Share.shareFiles([tempFile.path]);
                            },
                            child: const Text('Share'),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () async {
                              final tempFile = await _imageFile;
                              await GallerySaver.saveImage(tempFile.path);
                              await tempFile.delete();
                            },
                            child: const Text('Save to camera roll'),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child:
                            Text('Saving and sharing collages is currently not '
                                'supported on web.'),
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
