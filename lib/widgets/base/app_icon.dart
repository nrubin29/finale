import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({required this.size});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .22),
    child: Image.asset('assets/images/icon.png', width: size),
  );
}
