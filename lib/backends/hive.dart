import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:hive/hive.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class HiveBenchmark extends Benchmark {
  HiveBenchmark() : super('Hive', Color.fromHex(code: '#8ecae6'));

  late final Box box;

  @override
  Future<void> setup() async {
    Hive.registerAdapter(DocumentAdapter());
    box = await Hive.openBox<Document>(
      'benchmark${Random().nextInt(1000)}',
    );
  }

  @override
  Future<void> addAll(List<Document> docs) async {
    for (var doc in docs) {
      await box.add(doc);
    }
  }

  @override
  Future<void> reset() => box.clear();

  @override
  FutureOr<void> get(Document doc) => box.get(doc.id);

  @override
  Future<void> removeAll(List<Document> docs) async {
    for (var doc in docs) {
      await box.delete(doc.id);
    }
  }
}
