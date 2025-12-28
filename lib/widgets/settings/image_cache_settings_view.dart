import 'dart:io';

import 'package:collection/collection.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/image_id_cache.dart';
import 'package:finale/widgets/base/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheSettingsView extends StatefulWidget {
  @override
  State<ImageCacheSettingsView> createState() => _ImageCacheSettingsViewState();
}

class _ImageCacheSettingsViewState extends State<ImageCacheSettingsView> {
  int? _numObjects;
  int? _totalBytes;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final repo = DefaultCacheManager().config.repo;
    await repo.open();
    final allObjects = await repo.getAllObjects();
    final totalBytes = allObjects.map((o) => o.length).nonNulls.sum;
    setState(() {
      _numObjects = allObjects.length;
      _totalBytes = totalBytes;
    });
  }

  void _clearCache() async {
    await DefaultCacheManager().emptyCache();
    await ImageIdCache().drop();

    // Manually delete all files in the cache directory. For some
    // reason, flutter_cache_manager doesn't seem to do this.
    // Logic copied from file_system_io.dart:15
    final baseDir = await getTemporaryDirectory();
    final subDir = Directory('${baseDir.path}/${DefaultCacheManager.key}');
    await subDir.delete(recursive: true);

    _loadStats();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: createAppBar(context, 'Image Cache'),
    body: Column(
      children: [
        if (_numObjects != null)
          ListTile(
            leading: const Icon(Icons.image),
            title: Text('Number of images: $_numObjects'),
          ),
        if (_totalBytes != null)
          ListTile(
            leading: const Icon(Icons.save),
            title: Text('Total size: ${formatFileSize(_totalBytes!)}'),
          ),
        ListTile(
          title: const Text('Empty image cache'),
          leading: const Icon(Icons.delete),
          onTap: _clearCache,
        ),
      ],
    ),
  );
}
