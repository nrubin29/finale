import 'package:finale/services/lastfm/user.dart';
import 'package:flutter/material.dart';

class ProfileStack extends StatefulWidget {
  final Widget child;

  const ProfileStack({required this.child});

  static ProfileStackData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileStackData>()!;

  static ProfileStackData find(BuildContext context) =>
      context.findAncestorWidgetOfExactType<ProfileStackData>()!;

  @override
  State<ProfileStack> createState() => _ProfileStackState();
}

class _ProfileStackState extends State<ProfileStack> {
  var _usernames = <String>[];
  LUser? _me;

  @override
  Widget build(BuildContext context) => ProfileStackData(
    usernames: _usernames,
    me: _me,
    onPush: (username) {
      setState(() {
        _usernames = [..._usernames, username];
      });
    },
    onPop: () {
      if (!mounted) return;
      setState(() {
        _usernames = _usernames.sublist(0, _usernames.length - 1);
      });
    },
    onSetMe: (me) {
      setState(() {
        _me = me;
      });
    },
    child: widget.child,
  );
}

/// Keeps track of [ProfileWidget]s as they are added and removed.
///
/// This widget can be used to determine the username of the friend who
/// (indirectly) linked the user to the page they're currently viewing.
class ProfileStackData extends InheritedWidget {
  final List<String> _usernames;
  final LUser? _me;
  final void Function(String username) _onPush;
  final void Function() _onPop;
  final void Function(LUser me) _onSetMe;

  const ProfileStackData({
    required List<String> usernames,
    required LUser? me,
    required void Function(String username) onPush,
    required void Function() onPop,
    required void Function(LUser me) onSetMe,
    required super.child,
  }) : _usernames = usernames,
       _me = me,
       _onPush = onPush,
       _onPop = onPop,
       _onSetMe = onSetMe;

  LUser get me => _me!;

  set me(LUser me) {
    _onSetMe(me);
  }

  /// The username of the friend whose profile is first in the stack.
  ///
  /// Since the user's own profile will always be first in the stack, it is
  /// ignored, and null is returned.
  String? get friendUsername => _usernames.length <= 1 ? null : _usernames.last;

  void push(String username) {
    _onPush(username);
  }

  void pop() {
    _onPop();
  }

  @override
  bool updateShouldNotify(ProfileStackData oldWidget) => true;
}
