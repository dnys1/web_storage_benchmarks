import 'dart:async';

import 'package:charts_flutter/flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class SharedPrefsBenchmark extends Benchmark {
  SharedPrefsBenchmark()
      : super('Shared Prefs', Color.fromHex(code: '#fb8500'));

  late final SharedPreferences sharedPrefs;

  @override
  Future<void> setup() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> addAll(List<Document> docs) {
    final futures = <Future<void>>[];
    for (var doc in docs) {
      futures.add(sharedPrefs.setDouble(doc.id, doc.data));
    }
    return Future.wait(futures);
  }

  @override
  void get(Document doc) => sharedPrefs.get(doc.id);

  @override
  Future<void> removeAll(List<Document> docs) {
    final futures = <Future<void>>[];
    for (var doc in docs) {
      futures.add(sharedPrefs.remove(doc.id));
    }
    return Future.wait(futures);
  }

  @override
  Future<void> reset() => sharedPrefs.clear();
}
