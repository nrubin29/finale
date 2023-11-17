import 'package:finale/util/preferences.dart';
import 'package:finale/util/profile_tab.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';

class ProfileTabsSettingsView extends StatefulWidget {
  const ProfileTabsSettingsView();

  @override
  State<StatefulWidget> createState() => _ProfileTabsSettingsViewState();
}

class _ProfileTabsSettingsViewState extends State<ProfileTabsSettingsView> {
  late List<ProfileTab> _tabOrder;
  late Map<ProfileTab, bool> _tabEnabled;

  @override
  void initState() {
    super.initState();

    final preferencesTabOrder = Preferences.profileTabsOrder.value;
    _tabOrder = [...ProfileTab.values]..sort((a, b) {
        var aIndex = preferencesTabOrder.indexOf(a);
        if (aIndex == -1) aIndex = 10;

        var bIndex = preferencesTabOrder.indexOf(b);
        if (bIndex == -1) bIndex = 10;

        return aIndex.compareTo(bIndex);
      });
    _tabEnabled = Map.fromEntries(ProfileTab.values
        .map((e) => MapEntry(e, preferencesTabOrder.contains(e))));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final tab = _tabOrder.removeAt(oldIndex);
      _tabOrder.insert(newIndex, tab);
    });
  }

  void _onCheckboxChanged(ProfileTab tab, bool value) {
    setState(() {
      _tabEnabled[tab] = value;
    });
  }

  void _reset() {
    setState(() {
      _tabOrder = [...ProfileTab.values];
      _tabEnabled = Map.fromIterable(ProfileTab.values, value: (_) => true);
    });
  }

  Future<bool> _save(_) async {
    Preferences.profileTabsOrder.value =
        _tabOrder.where((e) => _tabEnabled[e]!).toList(growable: false);
    return true;
  }

  bool get _allowUncheck =>
      _tabEnabled.values.where((element) => element).length > 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBar(
        'Profile Tabs',
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: PopScope(
        onPopInvoked: _save,
        child: ReorderableListView(
          onReorder: _onReorder,
          children: [
            for (final tab in _tabOrder)
              ListTile(
                key: ValueKey(tab),
                title: Text(tab.displayName),
                leading: Icon(tab.icon),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _tabEnabled[tab],
                      onChanged: (value) {
                        if (!value! && !_allowUncheck) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content:
                                    Text('You must enable at least two tabs.'),
                              ),
                            );

                          return;
                        }

                        _onCheckboxChanged(tab, value);
                      },
                    ),
                    const Icon(Icons.drag_handle),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
