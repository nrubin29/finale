import 'package:finale/services/generic.dart';
import 'package:flutter/material.dart';

Future<void> showNoEntityTypePeriodDialog(BuildContext context,
        {required EntityType entityType, required String username}) =>
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No ${entityType.name}s'),
        content:
            Text("$username hasn't scrobbled any ${entityType.name}s in this "
                "period."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
