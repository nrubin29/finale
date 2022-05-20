import 'package:flutter/material.dart';

/// Keeps track of [ProfileWidget]s as they are added and removed.
///
/// This widget can be used to determine the username of the friend who
/// (indirectly) linked the user to the page they're currently viewing.
class ProfileStack extends InheritedWidget {
  final List<String> _usernames;

  ProfileStack({required super.child})
      : _usernames = <String>[];

  static ProfileStack of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileStack>()!;

  static ProfileStack find(BuildContext context) =>
      context.findAncestorWidgetOfExactType<ProfileStack>()!;

  /// The username of the friend whose profile is first in the stack.
  ///
  /// Since the user's own profile will always be first in the stack, it is
  /// ignored, and null is returned.
  String? get friendUsername => _usernames.length <= 1 ? null : _usernames.last;

  void push(String username) {
    _usernames.add(username);
  }

  void pop() {
    _usernames.removeLast();
  }

  @override
  bool updateShouldNotify(ProfileStack oldWidget) => true;
}
