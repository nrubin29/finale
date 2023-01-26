import 'package:finale/services/lastfm/common.dart';
import 'package:flutter/material.dart';

class FractionalBar extends StatelessWidget {
  final double percent;

  const FractionalBar(this.percent);

  FractionalBar.forEntity(HasPlayCount item, List<HasPlayCount> items)
      : percent = item.playCount / items.first.playCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SizedBox(
          height: 4,
          child: FractionallySizedBox(
            widthFactor: percent,
            alignment: Alignment.centerRight,
            child: Material(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
}
