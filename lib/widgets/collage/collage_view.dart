import 'dart:async';
import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/list_tile_text_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/base/two_up.dart';
import 'package:finale/widgets/collage/src/grid_collage.dart';
import 'package:finale/widgets/collage/src/list_collage.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:finale/widgets/collage/collage_web_warning_dialog.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:universal_io/io.dart';

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
  final _screenshotController = ScreenshotController();

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

    _updateRequest();
  }

  final _requestStreamController = BehaviorSubject<PagedRequest<Entity>>();

  void _updateRequest() {
    final username = _usernameTextController.text;

    if (_chart == EntityType.album) {
      _requestStreamController.add(GetTopAlbumsRequest(username, _period));
    } else if (_chart == EntityType.artist) {
      _requestStreamController.add(GetTopArtistsRequest(username, _period));
    } else if (_chart == EntityType.track) {
      _requestStreamController.add(GetTopTracksRequest(username, _period));
    } else {
      throw Exception('$_chart is not supported for collages.');
    }
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

    await Future.wait(items.map((item) async {
      await item.tryCacheImageId();
      setState(() {
        _loadingProgress++;
      });
    }));

    // final image = await _screenshotController.captureFromWidget(
    //   _type == DisplayType.list
    //       ? ListCollage(_themeColor, _includeTitle, _includeBranding, _period,
    //           _chart, request)
    //       : GridCollage(_gridSize, _includeTitle, _includeText,
    //           _includeBranding, _period, _chart, request),
    //   pixelRatio: 3,
    //   context: context,
    // );
    //
    // setState(() {
    //   _image = image;
    //   _isDoingRequest = false;
    // });
  }

  Future<File> get _imageFile async {
    final tempDir = (await getTemporaryDirectory()).path;
    final tempFile = File('$tempDir/collage.png');
    await tempFile.writeAsBytes(_image!);
    return tempFile;
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
                      onChanged: (_) {
                        // TODO: debounce. Add to a stream here and listen to a
                        //  debounced version to call _updateRequest().
                        _updateRequest();
                      },
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
                                _updateRequest();
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
                            _updateRequest();
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
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 10),
                    //   child: OutlinedButton(
                    //     onPressed: () {
                    //       _doRequest(context);
                    //     },
                    //     child: const Text('Generate'),
                    //   ),
                    // ),
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
  /// On mobile, the image will be saved to the camera roll. On web, the image
  /// will be downloaded as a png file. Image saving is not supported on
  /// desktop.
  Future<void> _saveImage() async {
    print('Going to save.');
    if (isMobile) {
      _image = await _screenshotController.capture(pixelRatio: 3);
      print('Done capturing.');
      final tempFile = await _imageFile;
      await GallerySaver.saveImage(tempFile.path);
      await tempFile.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to camera roll!')));
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
            builder: (context) => TwoUp(
                first: SingleChildScrollView(child: _form(context)),
                second: SingleChildScrollView(
                  child: Column(children: [
                    Screenshot(
                      controller: _screenshotController,
                      child: _type == DisplayType.list
                          ? ListCollage(
                              _themeColor,
                              _includeTitle,
                              _includeBranding,
                              _period,
                              _chart,
                              _requestStreamController.stream)
                          : GridCollage(
                              _gridSize,
                              _includeTitle,
                              _includeText,
                              _includeBranding,
                              _period,
                              _chart,
                              _requestStreamController.stream),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TODO: Move share and camera roll buttons to the
                        //  AppBar.
                        if (!isWeb)
                          Builder(
                              builder: (context) => OutlinedButton(
                                    onPressed: () async {
                                      final box = context.findRenderObject()
                                          as RenderBox;
                                      final position =
                                          box.localToGlobal(Offset.zero) &
                                              box.size;

                                      final tempFile = await _imageFile;
                                      await Share.shareFiles([tempFile.path],
                                          sharePositionOrigin: position);
                                    },
                                    child: const Text('Share'),
                                  )),
                        // Both buttons are visible only on mobile.
                        if (isMobile) const SizedBox(width: 10),
                        if (!isDesktop)
                          OutlinedButton(
                            onPressed: _saveImage,
                            child: const Text(
                                isWeb ? 'Download' : 'Save to camera roll'),
                          ),
                      ],
                    ),
                  ]),
                ))

            // Center(
            //   child: _isDoingRequest
            //       ? _loadingWidget
            //       : ListView(children: [
            //           _form(context),
            //           _type == DisplayType.list
            //               ? ListCollage(
            //                   _themeColor,
            //                   _includeTitle,
            //                   _includeBranding,
            //                   _period,
            //                   _chart,
            //                   _requestStreamController.stream)
            //               : GridCollage(
            //                   _gridSize,
            //                   _includeTitle,
            //                   _includeText,
            //                   _includeBranding,
            //                   _period,
            //                   _chart,
            //                   _requestStreamController.stream),
            //           const SizedBox(height: 16),
            //           // Center(
            //           //   child: ConstrainedBox(
            //           //     constraints: _type == DisplayType.grid
            //           //         ? const BoxConstraints(maxWidth: 600)
            //           //         : const BoxConstraints(maxWidth: 400),
            //           //     child: Image.memory(_image!),
            //           //   ),
            //           // ),
            //           const SizedBox(height: 10),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               if (!isWeb)
            //                 Builder(
            //                     builder: (context) => OutlinedButton(
            //                           onPressed: () async {
            //                             final box =
            //                                 context.findRenderObject()
            //                                     as RenderBox;
            //                             final position =
            //                                 box.localToGlobal(Offset.zero) &
            //                                     box.size;
            //
            //                             final tempFile = await _imageFile;
            //                             await Share.shareFiles(
            //                                 [tempFile.path],
            //                                 sharePositionOrigin: position);
            //                           },
            //                           child: const Text('Share'),
            //                         )),
            //               // Both buttons are visible only on mobile.
            //               if (isMobile) const SizedBox(width: 10),
            //               if (!isDesktop)
            //                 OutlinedButton(
            //                   onPressed: _saveImage,
            //                   child: const Text(isWeb
            //                       ? 'Download'
            //                       : 'Save to camera roll'),
            //                 ),
            //             ],
            //           ),
            //         ]),
            // )
            ),
      );

  @override
  void dispose() {
    _usernameTextController.dispose();
    _periodChangeSubscription.cancel();
    _themeColorChangeSubscription.cancel();
    super.dispose();
  }
}
