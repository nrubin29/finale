import 'package:finale/services/generic.dart';
import 'package:finale/util/error_details.dart';
import 'package:flutter/material.dart';

Future<void> showNoEntityTypePeriodDialog(BuildContext context,
        {required EntityType entityType, required String username}) =>
    showDialog(
      context: context,
      builder: (_) => _MessageDialog(
        title: 'No ${entityType.name}s',
        content: "$username hasn't scrobbled any ${entityType.name}s in this "
            "period.",
      ),
    );

Future<void> showExceptionDialog(BuildContext context,
    {required Exception error,
    required StackTrace stackTrace,
    Object? detailObject}) {
  final details = ErrorDetails(
      error: error, stackTrace: stackTrace, detailObject: detailObject);
  return showDialog(
    context: context,
    builder: (_) => _MessageDialog(
      title: details.title,
      content: '${details.error}',
      icon: details.icon,
    ),
  );
}

class _MessageDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _MessageDialog(
      {required this.title, required this.content, this.icon = Icons.error});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Row(children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(title),
        ]),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      );
}
