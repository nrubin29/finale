import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/common.dart';
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

Future<void> showLExceptionDialog(BuildContext context,
        {required LException error, required String username}) =>
    showDialog(
      context: context,
      builder: (_) => _MessageDialog(
          title: error.message == 'User not found' ? 'User not found' : 'Error',
          content: error.message == 'User not found'
              ? 'User $username does not exist.'
              : error.message),
    );

class _MessageDialog extends StatelessWidget {
  final String title;
  final String content;

  const _MessageDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
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
