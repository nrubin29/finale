import 'package:finale/services/lastfm/common.dart';
import 'package:flutter/material.dart';

class PlayCountBar<T extends HasPlayCount> extends StatelessWidget {
  final T item;
  final List<T> items;

  const PlayCountBar(this.item, this.items);

  double get percent => item.playCount / items.first.playCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          height: 4,
          child: FractionallySizedBox(
            widthFactor: percent,
            alignment: Alignment.centerRight,
            child: const Material(color: Colors.red),
          ),
        ),
      );
}
