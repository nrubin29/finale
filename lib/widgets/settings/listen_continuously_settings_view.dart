import 'package:finale/util/preferences.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class ListenContinuouslySettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenContinuouslySettingsViewState();
}

class _ListenContinuouslySettingsViewState
    extends State<ListenContinuouslySettingsView> {
  late bool _stripTags;

  @override
  void initState() {
    super.initState();
    _stripTags = Preferences().stripTags;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar('Listen Continuously Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Strip tags'),
            leading: const Icon(Icons.label_off),
            trailing: Switch(
              value: _stripTags,
              onChanged: (_) {
                setState(() {
                  _stripTags = (Preferences().stripTags = !_stripTags);
                });
              },
            ),
          ),
          SafeArea(
            top: false,
            bottom: false,
            minimum: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
                'Removes tags like (Live) or [Demo] from track titles. This '
                'can help with double scrobbles when the continuous scrobbler '
                'finds multiple names for the same track.',
                style: Theme.of(context).textTheme.caption),
          ),
        ],
      ),
    );
  }
}
