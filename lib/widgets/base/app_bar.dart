import 'package:flutter/material.dart';

/// Creates an [AppBar] whose [title] and [subtitle] will always fit.
AppBar createAppBar(String title,
        {String? subtitle, Color? backgroundColor, List<Widget>? actions}) =>
    AppBar(
      backgroundColor: backgroundColor,
      centerTitle: true,
      title: Column(
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
    );
