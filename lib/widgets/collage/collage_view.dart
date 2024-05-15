import 'dart:async';
import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/widget_image_capturer.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/collage/src/grid_collage.dart';
import 'package:finale/widgets/collage/src/list_collage.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/collage/collage_web_warning_dialog.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' show AnchorElement;

class CollageView extends StatefulWidget {
  const CollageView();

  @override
  State<StatefulWidget> createState() => _CollageViewState();
}

class _CollageViewState extends State<CollageView> {
  var _isSettingsExpanded = true;
  final _usernameTextController =
      TextEditingController(text: Preferences.name.value);
  var _chart = EntityType.album;
  var _type = DisplayType.grid;
  late Period _period;
  var _gridSize = 5;
  var _includeTitle = true;
  var _includeText = true;
  late ThemeColor _themeColor;
  var _includeBranding = true;

  var _isDoingRequest = false;
  var _loadingProgress = 0;
  var _numItemsToLoad = 0;
  Uint8List? _image;

  late StreamSubscription _periodChangeSubscription;
  late StreamSubscription _themeColorChangeSubscription;

  int get _numGridItems => _gridSize * _gridSize;

  @override
  void initState() {
    super.initState();

    _periodChangeSubscription = Preferences.period.changes.listen((value) {
      if (mounted) {
        setState(() {
          _period = value;
        });
      }
    });

    _themeColorChangeSubscription =
        Preferences.themeColor.changes.listen((value) {
      if (mounted) {
        setState(() {
          _themeColor = value;
        });
      }
    });

    _period = Preferences.period.value;
    _themeColor = Preferences.themeColor.value;
  }

  Future<void> _doRequest(BuildContext context) async {
    setState(() {
      _loadingProgress = 0;
      _numItemsToLoad = _type == DisplayType.grid
          ? _numGridItems
          : _includeTitle
              ? 4
              : 5;
      _isDoingRequest = true;
      _isSettingsExpanded = false;
      _image = null;
    });

    PagedRequest<Entity> request;
    final username = _usernameTextController.text;

    if (_chart == EntityType.album) {
      request = GetTopAlbumsRequest(username, _period);
    } else if (_chart == EntityType.artist) {
      request = GetTopArtistsRequest(username, _period);
    } else if (_chart == EntityType.track) {
      request = GetTopTracksRequest(username, _period);
    } else {
      throw Exception('$_chart is not supported for collages.');
    }

    List<Entity> items;

    try {
      items = await request.getData(_numItemsToLoad, 1);
    } on Exception catch (e, st) {
      setState(() {
        _isSettingsExpanded = true;
        _isDoingRequest = false;
      });

      showExceptionDialog(context,
          error: e, stackTrace: st, detailObject: username);
      return;
    }

    if (items.isEmpty) {
      showNoEntityTypePeriodDialog(context,
          entityType: _chart, username: username);

      setState(() {
        _isSettingsExpanded = true;
        _isDoingRequest = false;
      });

      return;
    }

    setState(() {
      _numItemsToLoad = items.length;
    });

    final streamController = StreamController<void>();
    final capturer = WidgetImageCapturer();

    void onEvent() {
      setState(() {
        _loadingProgress++;
      });
    }

    Future<void> onDone() async {
      // Wait for the widget to settle.
      await Future.delayed(const Duration(seconds: 1));

      final data = await capturer.captureImage();
      setState(() {
        _image = data.buffer.asUint8List();
        _isDoingRequest = false;
      });
    }

    streamController.stream
        .timeout(const Duration(seconds: 5), onTimeout: (_) {
          onDone();
        })
        .take(_numItemsToLoad)
        .listen(
          (_) {
            onEvent();
          },
          onError: (error, stackTrace) {
            FlutterError.dumpErrorToConsole(FlutterErrorDetails(
                exception: error, stack: stackTrace, library: 'CollageView'));
            onEvent();
          },
          onDone: onDone,
        );

    void onImageLoaded() {
      streamController.add(null);
    }

    capturer.setup(
      context,
      _type == DisplayType.list
          ? ListCollage(_themeColor, _includeTitle, _includeBranding, _period,
              _chart, items, onImageLoaded)
          : GridCollage(_gridSize, _includeTitle, _includeText,
              _includeBranding, _period, _chart, items, onImageLoaded),
    );
  }

  Widget _form(BuildContext context) => ExpansionPanelList(
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
                    ListTileTextField(
                      title: 'Username',
                      controller: _usernameTextController,
                    ),
                    ListTile(
                      title: const Text('Chart'),
                      trailing: DropdownButton<EntityType>(
                        value: _chart,
                        items: const [
                          DropdownMenuItem(
                            value: EntityType.album,
                            child: Text('Top Albums'),
                          ),
                          DropdownMenuItem(
                            value: EntityType.artist,
                            child: Text('Top Artists'),
                          ),
                          DropdownMenuItem(
                            value: EntityType.track,
                            child: Text('Top Tracks'),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value != null) {
                            var shouldSet = true;

                            if (isWeb &&
                                value == EntityType.artist &&
                                !Preferences.hasSpotifyAuthData) {
                              shouldSet = (await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          CollageWebWarningDialog())) ??
                                  false;
                            }

                            if (shouldSet) {
                              setState(() {
                                _chart = value;
                              });
                            }
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Type'),
                      trailing: DropdownButton<DisplayType>(
                        value: _type,
                        items: const [
                          DropdownMenuItem(
                            value: DisplayType.grid,
                            child: Text('Grid'),
                          ),
                          DropdownMenuItem(
                            value: DisplayType.list,
                            child: Text('List'),
                          ),
                        ],
                        onChanged: (value) async {
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
                      trailing: PeriodDropdownButton(
                        periodChanged: (period) {
                          setState(() {
                            _period = period;
                          });
                        },
                      ),
                    ),
                    if (_type == DisplayType.grid)
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
                      title: const Text('Include title'),
                      trailing: Switch(
                        value: _includeTitle,
                        onChanged: (value) {
                          if (value != _includeTitle) {
                            setState(() {
                              _includeTitle = value;
                            });
                          }
                        },
                      ),
                    ),
                    if (_type == DisplayType.grid)
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
                      )
                    else
                      ListTile(
                        title: const Text('Background color'),
                        trailing: DropdownButton<ThemeColor>(
                          value: _themeColor,
                          items: [
                            for (final themeColor in ThemeColor.values)
                              DropdownMenuItem(
                                value: themeColor,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: themeColor.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(themeColor.displayName),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _themeColor = value;
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: OutlinedButton(
                        onPressed: () {
                          _doRequest(context);
                        },
                        child: const Text('Generate'),
                      ),
                    ),
                  ],
                )),
          ]);

  Widget get _loadingWidget => SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: _loadingProgress / _numItemsToLoad,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$_loadingProgress / $_numItemsToLoad images loaded'),
              ],
            ),
          ],
        ),
      );

  /// Saves the image.
  ///
  /// On mobile and macOS, the image will be saved to the gallery. On web, the
  /// image will be downloaded as a png file.
  Future<void> _saveImage() async {
    if (!isWeb) {
      if (await Gal.requestAccess()) {
        await Gal.putImageBytes(_image!, name: 'collage');
      }
    } else {
      AnchorElement()
        ..href = Uri.dataFromBytes(_image!).toString()
        ..download = 'collage.png'
        ..style.display = 'none'
        ..click()
        ..remove();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: createAppBar('Collage Generator'),
        body: Builder(
            builder: (context) => Center(
                  child: _isDoingRequest
                      ? _loadingWidget
                      : ListView(children: [
                          _form(context),
                          if (_image != null) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: ConstrainedBox(
                                constraints: _type == DisplayType.grid
                                    ? const BoxConstraints(maxWidth: 600)
                                    : const BoxConstraints(maxWidth: 400),
                                child: Image.memory(_image!),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!isWeb) ...[
                                  Builder(
                                      builder: (context) => OutlinedButton(
                                            onPressed: () async {
                                              final box =
                                                  context.findRenderObject()
                                                      as RenderBox;
                                              final position =
                                                  box.localToGlobal(
                                                          Offset.zero) &
                                                      box.size;

                                              await Share.shareXFiles([
                                                XFile.fromData(_image!,
                                                    mimeType: 'image/png',
                                                    name: 'collage.png'),
                                              ], sharePositionOrigin: position);
                                            },
                                            child: const Text('Share'),
                                          )),
                                  const SizedBox(width: 10),
                                ],
                                OutlinedButton(
                                  onPressed: _saveImage,
                                  child: const Text(
                                      isWeb ? 'Download' : 'Save to gallery'),
                                ),
                              ],
                            ),
                          ],
                        ]),
                )),
      );

  @override
  void dispose() {
    _usernameTextController.dispose();
    _periodChangeSubscription.cancel();
    _themeColorChangeSubscription.cancel();
    super.dispose();
  }
}
