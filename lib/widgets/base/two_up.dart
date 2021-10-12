import 'package:flutter/material.dart';

/// Displays [image] and [listItems] side-by-side if there's enough room;
/// otherwise, displays [image] above [listItems].
class TwoUp extends StatelessWidget {
  final Widget? image;
  final List<Widget> listItems;

  const TwoUp({required this.image, required this.listItems});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTwoUp = mediaQuery.size.width > 600 &&
        mediaQuery.orientation == Orientation.landscape;
    return isTwoUp
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (image != null)
                Flexible(
                  fit: FlexFit.tight,
                  child: FractionallySizedBox(
                    widthFactor: .8,
                    heightFactor: .8,
                    child: image!,
                  ),
                ),
              Flexible(
                fit: FlexFit.tight,
                child: FractionallySizedBox(
                  widthFactor: image == null ? .8 : 1,
                  child: ListView(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    children: [const SizedBox(height: 16), ...listItems],
                  ),
                ),
              ),
            ],
          )
        : ListView(
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            children: [
              if (image != null)
                ConstrainedBox(
                  constraints:
                      BoxConstraints(maxHeight: mediaQuery.size.height / 2),
                  child: image!,
                ),
              const SizedBox(height: 10),
              ...listItems,
            ],
          );
  }
}
