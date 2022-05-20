import 'package:finale/services/generic.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

/// Creates an [AppBar] whose content will always fit.
///
/// If [leadingEntity] is specified, an [EntityImage] widget will be displayed
/// to the left of the [title] and [subtitle]. The image will be circular if
/// [circularLeadingImage] is `true`.
AppBar createAppBar(String title,
        {Entity? leadingEntity,
        bool circularLeadingImage = false,
        String? subtitle,
        Color? backgroundColor,
        List<Widget>? actions,
        PreferredSizeWidget? bottom}) =>
    AppBar(
      foregroundColor: Colors.white,
      backgroundColor: backgroundColor,
      centerTitle: true,
      title: leadingEntity != null
          ? FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  EntityImage(
                    entity: leadingEntity,
                    width: 40,
                    isCircular: circularLeadingImage,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 12),
                        )
                    ],
                  ),
                ],
              ),
            )
          : Column(
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(title),
                ),
                if (subtitle != null)
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
              ],
            ),
      actions: actions,
      bottom: bottom,
    );
