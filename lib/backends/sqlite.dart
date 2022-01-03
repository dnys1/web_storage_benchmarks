@JS()

import 'dart:async';

import 'package:charts_flutter/flutter.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

@JS()
external Object getSqlDb();

@JS('SQL.Database')
class SqlDatabase {
  external SqlDatabase();

  external void run(String query);
  external List<Object> exec(String query);
}

class SqliteBenchmark extends Benchmark {
  SqliteBenchmark()
      : super('SQLite', Color.fromHex(code: '#219ebc'), isJS: true);

  SqlDatabase? _db;

  @override
  void addAll(List<JSDocument> docs) {
    var query = '';
    for (var doc in docs) {
      query += 'INSERT INTO benchmark VALUES ("${doc.id}", ${doc.data});\n';
    }
    _db!.run(query);
  }

  @override
  void get(JSDocument doc) {
    _db!.exec('SELECT * FROM benchmark WHERE id="${doc.id}"');
  }

  @override
  void removeAll(List<JSDocument> docs) {
    var query = 'DELETE FROM benchmark';
    _db!.run(query);
  }

  @override
  Future<void> reset() async {
    _db!.run('DROP TABLE benchmark;');
    await setup();
  }

  @override
  Future<void> setup() async {
    _db ??= await promiseToFuture(getSqlDb());
    _db!.run('CREATE TABLE benchmark (id text, data real);');
  }
}
