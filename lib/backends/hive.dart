import 'dart:async';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/document.dart';

class HiveBenchmark extends Benchmark {
  HiveBenchmark() : super('Hive');

  late final Box box;

  @override
  Future<void> setup() async {
    Hive.registerAdapter(DocumentAdapter());
    box = await Hive.openBox<Document>(
      'benchmark${Random().nextInt(1000)}',
    );
  }

  @override
  Future<void> add(Document document) => box.add(document);

  @override
  Future<void> reset() => box.clear();

  @override
  FutureOr<void> get(Document document) => box.get(document.id);

  @override
  Future<void> remove(Document document) => box.delete(document.id);
}
