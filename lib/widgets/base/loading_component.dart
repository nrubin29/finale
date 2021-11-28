import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  final bool small;

  const LoadingComponent() : small = false;

  const LoadingComponent.small() : small = true;

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).backgroundColor,
        child: small
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: CircularProgressIndicator(),
                ),
              ),
      );
}
