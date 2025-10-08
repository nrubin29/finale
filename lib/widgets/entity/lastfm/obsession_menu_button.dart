import 'package:finale/services/lastfm/obsessions.dart';
import 'package:finale/widgets/entity/lastfm/set_obsession_button.dart';
import 'package:flutter/material.dart';

class ObsessionMenuButton extends StatelessWidget {
  final LObsession obsession;
  final void Function(LObsession obsession) onObsessionChange;

  const ObsessionMenuButton({
    required this.obsession,
    required this.onObsessionChange,
  });

  List<PopupMenuEntry> _buildItems(BuildContext context) {
    return [
      PopupMenuItem(
        child: const ListTile(
          leading: Icon(Icons.star_border),
          title: Text('Delete obsession'),
        ),
        onTap: () async {
          if (await deleteObsessionInUi(context, obsession)) {
            onObsessionChange(obsession.copyWith(isDeleted: true));
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton(
    itemBuilder: _buildItems,
    tooltip: 'Actions',
    child: const Icon(Icons.more_vert, color: Colors.grey),
  );
}
