import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class SembastBenchmark extends Benchmark {
  SembastBenchmark() : super('Sembast', Color.fromHex(code: '#023047'));

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
  Future<void> addAll(List<Document> docs) {
    final List<Future<void>> futures = [];
    for (var doc in docs) {
      futures.add(store.record(doc.id).add(database, doc.data));
    }
    return Future.wait(futures);
  }

  @override
  Future<void> reset() => store.drop(database);

  @override
  Future<void> get(Document doc) => store.record(doc.id).get(database);

  @override
  Future<void> removeAll(List<Document> docs) =>
      store.records(docs.map((doc) => doc.id)).delete(database);
}
