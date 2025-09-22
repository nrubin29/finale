import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({required this.size});

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/icon.png', width: size);
}
