import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:flutter/material.dart';

class LoveButton extends StatefulWidget {
  final LTrack track;

  const LoveButton({required this.track});

  @override
  State<StatefulWidget> createState() => _LoveButtonState();
}

class _LoveButtonState extends State<LoveButton> {
  late bool _isLoved;

  @override
  void initState() {
    super.initState();
    _isLoved = widget.track.userLoved;
  }

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(
          _isLoved ? Icons.favorite : Icons.favorite_border,
          color: Theme.of(context).primaryColor,
        ),
        onPressed: () async {
          if (await Lastfm.love(widget.track, !_isLoved)) {
            setState(() {
              _isLoved = !_isLoved;
            });
          }
        },
      );
}