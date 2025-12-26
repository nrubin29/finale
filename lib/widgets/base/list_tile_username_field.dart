import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/preferences.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/custom_list_tile.dart';
import 'package:flutter/material.dart';

class ListTileUsernameField extends StatefulWidget {
  final TextEditingController controller;
  final bool includeSelf;

  const ListTileUsernameField({
    required this.controller,
    this.includeSelf = true,
  });

  @override
  State<ListTileUsernameField> createState() => _ListTileUsernameFieldState();
}

class _ListTileUsernameFieldState extends State<ListTileUsernameField> {
  final _focusNode = FocusNode();
  var _friendUsernames = <String>[];

  @override
  void initState() {
    super.initState();
    _loadFriendUsernames();

    if (widget.includeSelf) {
      widget.controller.text = Preferences.name.value!;
    }
  }

  void _loadFriendUsernames() async {
    final myUsername = Preferences.name.value!;
    final friends = await GetFriendsRequest(myUsername).getAllData();
    if (!mounted) return;
    setState(() {
      _friendUsernames = [
        if (widget.includeSelf) myUsername,
        for (final friend in friends) friend.name,
      ];
    });
  }

  Iterable<String> _autocompleteOptions(TextEditingValue textEditingValue) =>
      _friendUsernames.where(
        (username) => username.toLowerCase().contains(
          textEditingValue.text.toLowerCase(),
        ),
      );

  String? _validator(String? value) =>
      value == null || value.isEmpty ? 'This field is required.' : null;

  @override
  Widget build(BuildContext context) => CustomListTile(
    title: 'Username',
    trailing: Autocomplete(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: _autocompleteOptions,
      fieldViewBuilder:
          (_, textEditingController, focusNode, onFieldSubmitted) =>
              TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
                textAlign: .end,
                validator: _validator,
                decoration: formElementBottomBorderDecoration,
                onFieldSubmitted: (_) => onFieldSubmitted(),
              ),
    ),
  );
}
