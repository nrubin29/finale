import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  final bool small;
  final String? message;

  const LoadingComponent({this.message}) : small = false;

  const LoadingComponent.small()
      : small = true,
        message = null;

  @override
  Widget build(BuildContext context) => Container(
        child: small
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 10),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
      );
}
