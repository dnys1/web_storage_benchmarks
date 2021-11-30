import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class SharedPrefsBenchmark extends Benchmark {
  SharedPrefsBenchmark() : super('Shared Prefs');

  late final SharedPreferences sharedPrefs;

  @override
  Future<void> setup() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  FutureOr<void> add(Document document) =>
      sharedPrefs.setDouble(document.id, document.data);

  @override
  FutureOr<void> get(Document document) => sharedPrefs.get(document.id);

  @override
  FutureOr<void> remove(Document document) => sharedPrefs.remove(document.id);

  @override
  Future<void> reset() => sharedPrefs.clear();
}
