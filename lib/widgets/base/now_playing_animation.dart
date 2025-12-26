import 'package:finale/util/constants.dart';
import 'package:flutter/material.dart';

class NowPlayingAnimation extends StatelessWidget {
  const NowPlayingAnimation();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 15,
    child: Row(
      mainAxisSize: .min,
      crossAxisAlignment: .end,
      children: [
        for (var i = 0; i < 3; i++) ...[
          _AnimatedBar(start: i / 2),
          if (i < 2) const SizedBox(width: 2),
        ],
      ],
    ),
  );
}

class _AnimatedBar extends StatefulWidget {
  final double start;

  const _AnimatedBar({required this.start});

  @override
  State<StatefulWidget> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.start,
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {});
    });

    if (isScreenshotTest) {
      if (widget.start == 0) {
        _controller.animateTo(.75);
      }
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    height: 15 * _controller.value,
    color: Theme.of(context).colorScheme.primary,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
