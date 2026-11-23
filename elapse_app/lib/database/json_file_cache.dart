import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// One cached payload: a small [meta] map (freshness info such as an expiry
/// or the server's `last_updated`) plus the raw response [body].
class JsonFileCacheEntry {
  final Map<String, dynamic> meta;
  final String body;

  const JsonFileCacheEntry(this.meta, this.body);
}

/// Disk cache for large JSON payloads (world-rankings datasets are MBs, which
/// is too big for SharedPreferences, since prefs is loaded into memory in full
/// at startup). Each key is one file: the first line is the meta JSON and the
/// rest is the body. Writes go to a temp file and are renamed into place, so a
/// crash mid-write never leaves a truncated entry behind. Every failure is
/// treated as a cache miss.
class JsonFileCache {
  static Future<Directory>? _dir;

  static Future<Directory> _directory() => _dir ??= () async {
        final base = await getApplicationSupportDirectory();
        final dir = Directory(p.join(base.path, "json_cache"));
        await dir.create(recursive: true);
        return dir;
      }();

  static Future<File> _file(String key) async => File(p.join((await _directory()).path, "$key.json"));

  static Future<JsonFileCacheEntry?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final newline = contents.indexOf("\n");
      if (newline < 0) return null;
      final meta = jsonDecode(contents.substring(0, newline)) as Map<String, dynamic>;
      return JsonFileCacheEntry(meta, contents.substring(newline + 1));
    } catch (e) {
      debugPrint("JsonFileCache.read($key) failed: $e");
      return null;
    }
  }

  /// Deletes every entry whose key matches [test], e.g. after a cache format change.
  static Future<void> deleteWhere(bool Function(String key) test) async {
    try {
      await for (final entity in (await _directory()).list()) {
        final name = p.basename(entity.path);
        if (entity is File && name.endsWith(".json") && test(name.substring(0, name.length - 5))) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint("JsonFileCache.deleteWhere failed: $e");
    }
  }

  static Future<void> write(String key, Map<String, dynamic> meta, String body) async {
    try {
      final file = await _file(key);
      final tmp = File("${file.path}.tmp");
      // jsonEncode never emits a raw newline, so line 1 is always the meta.
      await tmp.writeAsString("${jsonEncode(meta)}\n$body", flush: true);
      await tmp.rename(file.path);
    } catch (e) {
      debugPrint("JsonFileCache.write($key) failed: $e");
    }
  }
}
