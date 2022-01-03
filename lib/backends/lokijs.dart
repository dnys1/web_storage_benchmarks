@JS()

import 'dart:async';

import 'package:charts_flutter/flutter.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

@JS()
class IncrementalIndexedDBAdapter {
  external IncrementalIndexedDBAdapter();
}

@JS('loki')
class Loki {
  external Loki(String name, LokiOptions options);

  external LokiCollection addCollection(String name);
  external void saveDatabase(void Function(Object? err) callback);
  external void deleteDatabase();
  external void close(void Function() callback);
}

@JS()
@anonymous
class LokiOptions {
  external factory LokiOptions({
    required IncrementalIndexedDBAdapter adapter,
    bool autoload = true,
    bool autosave = true,
  });
}

@JS('loki.Collection')
class LokiCollection {
  external LokiCollection(String name);

  external void insert(JSDocument o);
  external JSDocument? findOne(Object o);
  external void remove(Object o);
  external void clear();
}

class LokiBenchmark extends Benchmark {
  LokiBenchmark() : super('Loki', Color.fromHex(code: '#ffb703'), isJS: true);

  late Loki loki;
  late LokiCollection collection;

  @override
  Future<void> addAll(List<JSDocument> docs) async {
    for (var doc in docs) {
      collection.insert(doc);
    }
    final completer = Completer<void>.sync();
    loki.saveDatabase(allowInterop((err) {
      if (err != null) {
        completer.completeError(err);
      }
      completer.complete();
    }));
    return completer.future;
  }

  @override
  void get(JSDocument doc) => collection.findOne(jsify({
        'id': doc.id,
      }));

  @override
  void removeAll(List<JSDocument> docs) => collection.remove(docs);

  @override
  Future<void> reset() async {
    final completer = Completer<void>.sync();
    loki.close(allowInterop(completer.complete));
    await completer.future;
    return setup();
  }

  @override
  Future<void> setup() async {
    loki = Loki(
      'benchmark${Benchmark.random.nextInt(1000)}',
      LokiOptions(adapter: IncrementalIndexedDBAdapter()),
    );
    collection = loki.addCollection('test${Benchmark.random.nextInt(1000)}');
  }
}
