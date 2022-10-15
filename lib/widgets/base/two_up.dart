import 'package:flutter/material.dart';

/// Displays [first] and [second] side-by-side if there's enough room;
/// otherwise, displays [first] above [second].
class TwoUp extends StatelessWidget {
  final Widget? first;
  final Widget second;

  const TwoUp({required this.first, required this.second});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTwoUp = mediaQuery.size.width > 600 &&
        mediaQuery.orientation == Orientation.landscape;
    return isTwoUp
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (first != null)
                Flexible(
                  fit: FlexFit.tight,
                  child: FractionallySizedBox(
                    // widthFactor: .8,
                    // heightFactor: .8,
                    child: first!,
                  ),
                ),
              Flexible(
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                  widthFactor: first == null ? .8 : 1,
                  child: second, // TODO: Maybe also const SizedBox(height: 16)
                ),
              ),
            ],
          )
        : ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: [
              if (first != null) first!,
                // ConstrainedBox(
                //   constraints:
                //       BoxConstraints(maxHeight: mediaQuery.size.height / 2),
                //   child: first!,
                // ),
              const SizedBox(height: 10),
              second,
            ],
          );
  }
}
