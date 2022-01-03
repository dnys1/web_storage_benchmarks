import 'dart:async';
import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:web_storage_benchmarks/backends/hive.dart';
import 'package:web_storage_benchmarks/backends/lokijs.dart';
import 'package:web_storage_benchmarks/backends/sembast.dart';
import 'package:web_storage_benchmarks/backends/shared_prefs.dart';
import 'package:web_storage_benchmarks/backends/sqlite.dart';
import 'package:web_storage_benchmarks/document.dart';

class TestResult {
  final String testName;
  final List<int> _results;
  final int numRuns;

  const TestResult(
    this.testName,
    this._results, {
    this.numRuns = 1,
  });

  double get average => _results.reduce((a, b) => a + b) / numRuns;

  double get logAverage => average > 0 ? log(average) / log(10) : 0;
}

abstract class Benchmark {
  const Benchmark(this.name, this.color, {this.isJS = false});

  static final random = Random(DateTime.now().millisecondsSinceEpoch);
  List<Document> get _docs => List.generate(
        100,
        (index) => Document(
          id: '${random.nextInt(1 << 31)}',
          data: random.nextDouble(),
        ),
      );
  List<JSDocument> get _jsDocs => List.generate(
        100,
        (index) => JSDocument(
          id: '${random.nextInt(1 << 31)}',
          data: random.nextDouble(),
        ),
      );
  static final all = [
    HiveBenchmark(),
    SqliteBenchmark(),
    SembastBenchmark(),
    LokiBenchmark(),
    SharedPrefsBenchmark(),
  ];

  final String name;
  final bool isJS;
  final Color color;

  Future<void> setup();
  Future<void> reset();

  FutureOr<void> addAll(covariant List<Document> docs);
  FutureOr<void> removeAll(covariant List<Document> docs);
  FutureOr<void> get(covariant Document doc);

  Future<List<TestResult>> run() async {
    await setup();

    final allRuns = <TestResult>[];

    // Add
    {
      final docs = isJS ? _jsDocs : _docs;
      List<int> results = [];
      final start = DateTime.now().millisecondsSinceEpoch;
      final addDocs = addAll(docs);
      if (addDocs is Future) await addDocs;
      final stop = DateTime.now().millisecondsSinceEpoch;
      final elapsed = stop - start;
      print('$name Add: $elapsed');
      results.add(elapsed);
      await reset();
      allRuns.add(TestResult('Add', results));
    }

    // Get
    {
      final docs = isJS ? _jsDocs : _docs;
      List<int> results = [];
      await addAll(docs);
      final start = DateTime.now().millisecondsSinceEpoch;
      for (var doc in docs) {
        final getDoc = get(doc);
        if (getDoc is Future) await getDoc;
      }
      final stop = DateTime.now().millisecondsSinceEpoch;
      final elapsed = stop - start;
      print('$name Get: $elapsed');
      results.add(elapsed);
      await reset();
      allRuns.add(TestResult('Get', results));
    }

    // Delete
    {
      final docs = isJS ? _jsDocs : _docs;
      final results = <int>[];
      await addAll(docs);
      final start = DateTime.now().millisecondsSinceEpoch;
      final removeDocs = removeAll(docs);
      if (removeDocs is Future) await removeDocs;
      final stop = DateTime.now().millisecondsSinceEpoch;
      final elapsed = stop - start;
      print('$name Delete: $elapsed');
      results.add(elapsed);
      await reset();
      allRuns.add(TestResult('Delete', results));
    }

    return allRuns;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Benchmark && name == other.name;
}
