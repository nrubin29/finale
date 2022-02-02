import 'package:flutter/material.dart';

/// Creates an [AppBar] whose [title] and [subtitle] will always fit.
AppBar createAppBar(String title,
        {Widget? leading,
        String? subtitle,
        Color? backgroundColor,
        List<Widget>? actions,
        PreferredSizeWidget? bottom}) =>
    AppBar(
      backgroundColor: backgroundColor,
      centerTitle: true,
      title: leading != null
          ? FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  leading,
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
