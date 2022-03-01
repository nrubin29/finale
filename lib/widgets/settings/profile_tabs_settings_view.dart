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

  @override
  void initState() {
    super.initState();
    _tabOrder = [...Preferences().profileTabsOrder];
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

  void _reset() {
    setState(() {
      _tabOrder = [...ProfileTab.values];
    });
  }

  Future<bool> _save() async {
    Preferences().profileTabsOrder = _tabOrder;
    return true;
  }

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
      body: WillPopScope(
        onWillPop: _save,
        child: ReorderableListView(
          onReorder: _onReorder,
          children: [
            for (final tab in _tabOrder)
              ListTile(
                key: ValueKey(tab),
                title: Text(tab.displayName),
                leading: Icon(tab.icon),
                trailing: const Icon(Icons.drag_handle),
              ),
          ],
        ),
      ),
    );
  }
}
