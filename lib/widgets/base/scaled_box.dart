import 'dart:math';

import 'package:flutter/material.dart';

/// Calculates the scale to which [builder] should build its subtree based on
/// [targetWidth] and the screen size.
///
/// The scale is computed as min(screen size, [targetWidth]) / [targetWidth]
/// meaning that if the widget fits on screen, the scale will be 1, and if not,
/// the scale will be a fraction less than 1.
class ScaledBox extends StatelessWidget {
  final double targetWidth;
  final Widget Function(BuildContext context, double scale) builder;

  const ScaledBox({required this.targetWidth, required this.builder});

  @override
  Widget build(BuildContext context) {
    final width = min(MediaQuery.of(context).size.width, targetWidth);
    final scale = width / targetWidth;
    return SizedBox(
      width: width,
      child: builder(context, scale),
    );
  }
}
