import 'package:finale/services/generic.dart';
import 'package:finale/util/error_details.dart';
import 'package:flutter/material.dart';

Future<void> showNoEntityTypePeriodDialog(
  BuildContext context, {
  required EntityType entityType,
  required String username,
}) => showDialog(
  context: context,
  builder: (_) => _MessageDialog(
    title: 'No ${entityType.name}s',
    content:
        "$username hasn't scrobbled any ${entityType.name}s in this "
        "period.",
  ),
);

Future<void> showExceptionDialog(
  BuildContext context, {
  required Exception error,
  required StackTrace stackTrace,
  Object? detailObject,
}) {
  final details = ErrorDetails(
    error: error,
    stackTrace: stackTrace,
    detailObject: detailObject,
  );
  return showDialog(
    context: context,
    builder: (_) => _MessageDialog(
      title: details.title,
      content: '${details.error}',
      icon: details.icon,
    ),
  );
}

Future<void> showMessageDialog(
  BuildContext context, {
  required String title,
  required String content,
}) => showDialog(
  context: context,
  builder: (_) => _MessageDialog(title: title, content: content),
);

Future<bool> showConfirmationDialog(
  BuildContext context, {
  String title = 'Confirm',
  required String content,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmationDialog(title: title, content: content),
    ) ??
    false;

Future<String?> showInputDialog(
  BuildContext context, {
  required String title,
  required String content,
  required IconData icon,
}) async => await showDialog<String?>(
  context: context,
  builder: (_) => _InputDialog(title: title, content: content, icon: icon),
);

class _MessageDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _MessageDialog({
    required this.title,
    required this.content,
    this.icon = Icons.error,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(children: [Icon(icon), const SizedBox(width: 10), Text(title)]),
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

class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;

  const _ConfirmationDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      spacing: 10,
      children: [const Icon(Icons.question_mark), Text(title)],
    ),
    content: Text(content),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: const Text('Yes'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, false);
        },
        child: const Text('No'),
      ),
    ],
  );
}

class _InputDialog extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;

  const _InputDialog({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(spacing: 10, children: [Icon(widget.icon), Text(widget.title)]),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.content),
        TextField(controller: _textController, focusNode: _focusNode),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context, _textController.text);
        },
        child: const Text('Save'),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context, null);
        },
        child: const Text('Cancel'),
      ),
    ],
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
