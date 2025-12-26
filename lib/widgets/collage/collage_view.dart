import 'dart:async';
import 'dart:typed_data';

import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/util/constants.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/util/widget_image_capturer.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:finale/widgets/base/collapsible_form_view.dart';
import 'package:finale/widgets/base/list_tile_username_field.dart';
import 'package:finale/widgets/base/period_dropdown.dart';
import 'package:finale/widgets/collage/collage_web_warning_dialog.dart';
import 'package:finale/widgets/collage/src/grid_collage.dart';
import 'package:finale/widgets/collage/src/list_collage.dart';
import 'package:finale/widgets/collage/src/wrapped_collage.dart';
import 'package:finale/widgets/entity/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_web/web.dart' show HTMLAnchorElement;

enum _CollageType { grid, list, wrapped }

class CollageView extends StatefulWidget {
  const CollageView();

  @override
  State<StatefulWidget> createState() => _CollageViewState();
}

class _CollageViewState extends State<CollageView> {
  final _usernameTextController = TextEditingController();
  var _chart = EntityType.album;
  var _type = _CollageType.grid;
  late Period _period;
  var _gridSize = 5;
  var _includeTitle = true;
  var _includeText = true;
  late ThemeColor _themeColor;
  var _includeBranding = true;

  var _loadingProgress = 0;
  var _numItemsToLoad = 0;

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

    _themeColorChangeSubscription = Preferences.themeColor.changes.listen((
      value,
    ) {
      if (mounted) {
        setState(() {
          _themeColor = value;
        });
      }
    });

    _period = Preferences.period.value;
    _themeColor = Preferences.themeColor.value;
  }

  Future<Uint8List?> _doRequest(BuildContext context) async {
    setState(() {
      _loadingProgress = 0;
      _numItemsToLoad = switch (_type) {
        .grid => _numGridItems,
        .list => _includeTitle ? 4 : 5,
        .wrapped => 1,
      };
    });

    PagedRequest<Entity> request;
    final username = _usernameTextController.text;

    if (_chart == .artist || _type == .wrapped) {
      request = GetTopArtistsRequest(username, _period);
    } else if (_chart == .album) {
      request = GetTopAlbumsRequest(username, _period);
    } else if (_chart == .track) {
      request = GetTopTracksRequest(username, _period);
    } else {
      throw Exception('$_chart is not supported for collages.');
    }

    var otherRequests = <Future<Object>>[];
    if (_type == .wrapped) {
      otherRequests = [
        GetTopArtistsRequest(username, _period).getData(5, 1),
        GetTopTracksRequest(username, _period).getData(5, 1),
        GetRecentTracksRequest.forPeriod(username, _period).getNumItems(),
      ];
    }

    List<Entity> items;
    var otherResults = <Object>[];

    try {
      items = await request.getData(_numItemsToLoad, 1);

      if (otherRequests.isNotEmpty) {
        otherResults = await Future.wait(otherRequests);
      }
    } on Exception catch (e, st) {
      if (!context.mounted) return null;
      showExceptionDialog(
        context,
        error: e,
        stackTrace: st,
        detailObject: username,
      );
      return null;
    }

    if (items.isEmpty) {
      if (!context.mounted) return null;
      showNoEntityTypePeriodDialog(
        context,
        entityType: _chart,
        username: username,
      );

      return null;
    }

    setState(() {
      _numItemsToLoad = items.length;
    });

    final streamController = StreamController<void>();
    final capturer = WidgetImageCapturer();
    final result = Completer<Uint8List?>();

    void onEvent() {
      setState(() {
        _loadingProgress++;
      });
    }

    Future<void> onDone() async {
      // Wait for the widget to settle.
      await Future.delayed(const Duration(seconds: 1));

      final data = await capturer.captureImage();
      result.complete(data.buffer.asUint8List());
    }

    streamController.stream
        .timeout(
          const Duration(seconds: 5),
          onTimeout: (_) {
            onDone();
          },
        )
        .take(_numItemsToLoad)
        .listen(
          (_) {
            onEvent();
          },
          onError: (error, stackTrace) {
            FlutterError.dumpErrorToConsole(
              FlutterErrorDetails(
                exception: error,
                stack: stackTrace,
                library: 'CollageView',
              ),
            );
            onEvent();
          },
          onDone: onDone,
        );

    void onImageLoaded() {
      streamController.add(null);
    }

    if (!context.mounted) return null;
    capturer.setup(context, switch (_type) {
      .grid => GridCollage(
        _gridSize,
        _includeTitle,
        _includeText,
        _includeBranding,
        _period,
        _chart,
        items,
        onImageLoaded,
      ),
      .list => ListCollage(
        _themeColor,
        _includeTitle,
        _includeBranding,
        _period,
        _chart,
        items,
        onImageLoaded,
      ),
      .wrapped => WrappedCollage(
        _themeColor,
        _includeBranding,
        username,
        _period,
        items,
        otherResults,
        onImageLoaded,
      ),
    });

    return result.future;
  }

  List<Widget> _formWidgetsBuilder(BuildContext context) => [
    ListTileUsernameField(controller: _usernameTextController),
    ListTile(
      title: const Text('Type'),
      trailing: DropdownButton<_CollageType>(
        value: _type,
        items: const [
          DropdownMenuItem(value: .grid, child: Text('Grid')),
          DropdownMenuItem(value: .list, child: Text('List')),
          DropdownMenuItem(value: .wrapped, child: Text('Wrapped')),
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
    if (_type != .wrapped)
      ListTile(
        title: const Text('Chart'),
        trailing: DropdownButton<EntityType>(
          value: _chart,
          items: const [
            DropdownMenuItem(value: .album, child: Text('Top Albums')),
            DropdownMenuItem(value: .artist, child: Text('Top Artists')),
            DropdownMenuItem(value: .track, child: Text('Top Tracks')),
          ],
          onChanged: (value) async {
            if (value != null) {
              var shouldSet = true;

              if (isWeb &&
                  value == .artist &&
                  !Preferences.hasSpotifyAuthData) {
                shouldSet =
                    (await showDialog(
                      context: context,
                      builder: (_) => CollageWebWarningDialog(),
                    )) ??
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
      title: const Text('Period'),
      trailing: PeriodDropdownButton(
        periodChanged: (period) {
          setState(() {
            _period = period;
          });
        },
      ),
    ),
    if (_type == .grid)
      ListTile(
        title: const Text('Grid size'),
        trailing: DropdownButton<int>(
          value: _gridSize,
          items: [
            for (var i = 3; i <= 10; i++)
              DropdownMenuItem(value: i, child: Text('${i}x$i')),
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
    if (_type != .wrapped)
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
    if (_type == .grid)
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
                  mainAxisSize: .min,
                  children: [
                    Icon(Icons.circle, color: themeColor.color),
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
  ];

  Widget _loadingWidgetBuilder(BuildContext context) => SafeArea(
    minimum: const .symmetric(horizontal: 16),
    child: Column(
      mainAxisSize: .min,
      children: [
        LinearProgressIndicator(
          value: _loadingProgress / _numItemsToLoad,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: .end,
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
  Future<void> _saveImage(Uint8List image) async {
    if (!isWeb) {
      if (await Gal.requestAccess()) {
        await Gal.putImageBytes(image, name: 'collage');
      }
    } else {
      HTMLAnchorElement()
        ..href = Uri.dataFromBytes(image).toString()
        ..download = 'collage.png'
        ..style.display = 'none'
        ..click()
        ..remove();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Collage Generator'),
    body: Builder(
      builder: (context) => CollapsibleFormView<Uint8List>(
        formWidgetsBuilder: _formWidgetsBuilder,
        loadingWidgetBuilder: _loadingWidgetBuilder,
        submitButtonText: 'Generate',
        bodyBuilder: (context, image) => Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: _type == .grid
                    ? const BoxConstraints(maxWidth: 600)
                    : const BoxConstraints(maxWidth: 400),
                child: Image.memory(image),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: .center,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final box = context.findRenderObject() as RenderBox;
                    final position = box.localToGlobal(.zero) & box.size;

                    await SharePlus.instance.share(
                      ShareParams(
                        files: [
                          .fromData(
                            image,
                            mimeType: 'image/png',
                            name: 'collage.png',
                          ),
                        ],
                        sharePositionOrigin: position,
                      ),
                    );
                  },
                  child: const Text('Share'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    _saveImage(image);
                  },
                  child: const Text(isWeb ? 'Download' : 'Save to gallery'),
                ),
              ],
            ),
          ],
        ),
        onFormSubmit: () => _doRequest(context),
      ),
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
