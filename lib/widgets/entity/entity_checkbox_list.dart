import 'package:collection/collection.dart';
import 'package:finale/services/generic.dart';
import 'package:finale/widgets/entity/entity_display.dart';
import 'package:flutter/material.dart';

class EntityCheckboxList<T extends Entity> extends StatefulWidget {
  final List<T> items;
  final void Function(List<T> selectedItems) onSelectionChanged;

  final bool scrollable;
  final bool displayImages;
  final String noResultsMessage;
  final RefreshCallback? onRefresh;
  final EntityWidgetBuilder<T>? trailingWidgetBuilder;

  const EntityCheckboxList({
    required this.items,
    required this.onSelectionChanged,
    this.scrollable = true,
    this.displayImages = true,
    this.noResultsMessage = 'No results.',
    this.onRefresh,
    this.trailingWidgetBuilder,
  });

  @override
  State<StatefulWidget> createState() => _EntityCheckboxList<T>();
}

class _EntityCheckboxList<T extends Entity>
    extends State<EntityCheckboxList<T>> {
  final _listEquality = ListEquality<T>();
  late Map<T, bool> _items;

  @override
  void initState() {
    super.initState();
    _itemsDidChange();
  }

  @override
  void didUpdateWidget(covariant EntityCheckboxList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_listEquality.equals(widget.items, oldWidget.items)) {
      _itemsDidChange();
    }
  }

  void _itemsDidChange() {
    _items = Map.fromIterable(widget.items, value: (_) => true);
  }

  void _updateItem(T item, bool selected) {
    setState(() {
      _items[item] = selected;
    });

    widget.onSelectionChanged(
        _items.keys.where((item) => _items[item]!).toList(growable: false));
  }

  void _updateAll({required bool isSelected}) {
    setState(() {
      _items.updateAll((_, __) => isSelected);
    });

    widget.onSelectionChanged(
        _items.keys.where((item) => _items[item]!).toList(growable: false));
  }

  @override
  Widget build(BuildContext context) => EntityDisplay<T>(
        items: _items.keys.toList(growable: false),
        scrollable: widget.scrollable,
        displayImages: widget.displayImages,
        noResultsMessage: widget.noResultsMessage,
        onRefresh: widget.onRefresh,
        onTap: (item) {
          _updateItem(item, !_items[item]!);
        },
        slivers: [
          if (_items.isNotEmpty)
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _updateAll(isSelected: true);
                    },
                    child: const Text('Select all'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      _updateAll(isSelected: false);
                    },
                    child: const Text('Deselect all'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
        ],
        leadingWidgetBuilder: (item) => Checkbox(
          value: _items[item],
          onChanged: (value) {
            if (value != null) {
              _updateItem(item, value);
            }
          },
        ),
        trailingWidgetBuilder: widget.trailingWidgetBuilder,
      );
}
