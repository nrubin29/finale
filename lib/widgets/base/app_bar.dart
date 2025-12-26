import 'package:finale/services/generic.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

/// Creates an [AppBar] whose content will always fit.
///
/// If [leadingEntity] is specified, an [EntityImage] widget will be displayed
/// to the left of the [title] and [subtitle]. The image will be circular if
/// [circularLeadingImage] is `true`.
PreferredSizeWidget createAppBar(
  BuildContext context,
  String title, {
  Entity? leadingEntity,
  bool circularLeadingImage = false,
  String? subtitle,
  Color? backgroundColor,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) => _PreferredSizeWrapper(
  parentBuilder: (child) => Theme(
    data: themeDataForAppBar(context, Preferences.themeColor.value),
    child: child,
  ),
  child: AppBar(
    backgroundColor: backgroundColor,
    centerTitle: true,
    title: leadingEntity != null
        ? FittedBox(
            fit: .fitWidth,
            child: Row(
              mainAxisAlignment: .center,
              mainAxisSize: .min,
              children: [
                EntityImage(
                  entity: leadingEntity,
                  width: 40,
                  isCircular: circularLeadingImage,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(title),
                    if (subtitle != null)
                      Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        : Column(
            children: [
              FittedBox(fit: .fitWidth, child: Text(title)),
              if (subtitle != null)
                FittedBox(
                  fit: .fitWidth,
                  child: Text(subtitle, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
    actions: actions,
    bottom: bottom,
  ),
);

/// A [CircularProgressIndicator] that fits nicely in [AppBar.actions].
class AppBarLoadingIndicator extends StatelessWidget {
  const AppBarLoadingIndicator();

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: null,
    child: Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          color: Preferences.themeColor.value.foregroundColor,
          strokeWidth: 2,
        ),
      ),
    ),
  );
}

class _PreferredSizeWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget Function(Widget child) parentBuilder;
  final PreferredSizeWidget child;

  const _PreferredSizeWrapper({
    required this.parentBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => parentBuilder(child);

  @override
  Size get preferredSize => child.preferredSize;
}
