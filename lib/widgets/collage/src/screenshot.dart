// This code is adapted from
// https://gist.github.com/itsJoKr/ce5ec57bd6dedf74d1737c1f39481913

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetImageCapturer {
  final _waitForCapture = Completer<void>();
  final _result = Completer<Uint8List>();

  void setup(BuildContext context, Widget widget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayState overlayState = Overlay.of(context);

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) {
          return _Helper(
            widget: widget,
            waitForCapture: _waitForCapture.future,
            callback: (data) {
              _result.complete(data);
              entry.remove();
            },
          );
        },
        maintainState: true,
      );

      overlayState.insert(entry);
    });
  }

  Future<Uint8List> captureImage() {
    _waitForCapture.complete();
    return _result.future;
  }
}

class _Helper extends StatefulWidget {
  final Widget widget;
  final Future<void> waitForCapture;
  final void Function(Uint8List data) callback;

  const _Helper({
    required this.widget,
    required this.waitForCapture,
    required this.callback,
  });

  @override
  _HelperState createState() => _HelperState();
}

class _HelperState extends State<_Helper> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _waitAndCapture();
  }

  Future<void> _waitAndCapture() async {
    await widget.waitForCapture;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final boundary =
          _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      widget.callback(byteData!.buffer.asUint8List());
    });

    // Force the post-frame callback to trigger.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: Offset(MediaQuery.of(context).size.width, 0),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              RepaintBoundary(
                key: _key,
                child: widget.widget,
              ),
            ],
          ),
        ),
      );
}
