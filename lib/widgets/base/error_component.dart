import 'package:finale/util/error_details.dart';
import 'package:finale/widgets/main/login_view.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorComponent extends StatelessWidget {
  final ErrorDetails details;
  final VoidCallback? onRetry;

  ErrorComponent(
      {required Exception error,
      required StackTrace stackTrace,
      Object? detailObject,
      this.onRetry})
      : details = ErrorDetails(
            error: error, stackTrace: stackTrace, detailObject: detailObject);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            details.icon,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            details.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            '${details.error}',
            textAlign: TextAlign.center,
          ),
          if (onRetry != null || details.canSendFeedback) ...[
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (details.canLogOut)
                  OutlinedButton(
                    onPressed: () {
                      LoginView.logOutAndShow(context);
                    },
                    child: const Text('Log out'),
                  ),
                if (onRetry != null)
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                if (details.canSendFeedback)
                  OutlinedButton(
                    onPressed: () async {
                      launchUrl(await details.emailUri);
                    },
                    child: const Text('Send feedback'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
