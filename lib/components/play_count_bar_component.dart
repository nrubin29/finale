import 'package:finale/services/lastfm/common.dart';
import 'package:flutter/material.dart';

class PlayCountBarComponent<T extends HasPlayCount> extends StatelessWidget {
  final T item;
  final List<T> items;

  PlayCountBarComponent(this.item, this.items);

  double get percent => item.playCount / items.first.playCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Container(
          height: 4,
          child: FractionallySizedBox(
            widthFactor: percent,
            alignment: Alignment.centerRight,
            child: Material(color: Colors.red),
          ),
        ),
      );
}
