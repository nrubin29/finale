// This code is adapted from
// https://gist.github.com/itsJoKr/ce5ec57bd6dedf74d1737c1f39481913

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetImageCapturer {
  final _key = GlobalKey<_HelperState>();
  late final OverlayEntry _overlayEntry;

  void setup(BuildContext context, Widget widget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry = OverlayEntry(
        builder: (_) {
          return _Helper(key: _key, widget: widget);
        },
        maintainState: true,
      );

      Overlay.of(context).insert(_overlayEntry);
    });
  }

  Future<Uint8List> captureImage() async {
    final data = await _key.currentState!._capture();
    _overlayEntry.remove();
    return data;
  }
}

class _Helper extends StatefulWidget {
  final Widget widget;

  const _Helper({super.key, required this.widget});

  @override
  _HelperState createState() => _HelperState();
}

class _HelperState extends State<_Helper> {
  final _key = GlobalKey();

  Future<Uint8List> _capture() {
    final completer = Completer<Uint8List>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final boundary =
          _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      completer.complete(byteData!.buffer.asUint8List());
    });

    // Force the post-frame callback to trigger.
    WidgetsBinding.instance.scheduleFrame();

    return completer.future;
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(MediaQuery.of(context).size.width, 0),
    child: Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [RepaintBoundary(key: _key, child: widget.widget)],
      ),
    ),
  );
}
