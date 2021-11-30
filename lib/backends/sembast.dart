import 'dart:async';
import 'dart:math';

import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class SembastBenchmark extends Benchmark {
  SembastBenchmark() : super('Sembast');

  static final factory = databaseFactoryWeb;
  late final Database database;
  final StoreRef<String, Object> store = StoreRef.main();

  @override
  Future<void> setup() async {
    database = await factory.openDatabase(
      'benchmark${Random().nextInt(1000)}',
      mode: DatabaseMode.create,
    );
  }

  @override
  Future<void> add(Document document) =>
      store.record(document.id).add(database, document.data);

  @override
  Future<void> reset() => store.drop(database);

  @override
  Future<void> get(Document document) =>
      store.record(document.id).get(database);

  @override
  Future<void> remove(Document document) =>
      store.record(document.id).delete(database);
}
