import 'dart:async';
import 'dart:math';

import 'package:web_storage_benchmarks/backends/hive.dart';
import 'package:web_storage_benchmarks/backends/sembast.dart';
import 'package:web_storage_benchmarks/backends/shared_prefs.dart';
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

  double get logAverage => average > 0 ? log(average) : 0;
}

abstract class Benchmark {
  const Benchmark(this.name);

  static final _random = Random();
  static final _docs = List.generate(
    100,
    (index) => Document(id: '$index', data: _random.nextDouble()),
  );
  static final all = [
    HiveBenchmark(),
    SembastBenchmark(),
    SharedPrefsBenchmark(),
  ];

  final String name;

  Future<void> setup();
  Future<void> reset();

  FutureOr<void> add(Document document);
  FutureOr<void> remove(Document document);
  FutureOr<void> get(Document document);

  Future<List<TestResult>> run() async {
    await setup();

    final allRuns = <TestResult>[];

    // Add
    {
      List<int> results = [];
      final stopwatch = Stopwatch()..start();
      for (var doc in _docs) {
        final addDoc = add(doc);
        if (addDoc is Future) await addDoc;
      }
      stopwatch.stop();
      print('$name Add: ${stopwatch.elapsedMilliseconds}');
      results.add(stopwatch.elapsedMilliseconds);
      await reset();
      allRuns.add(TestResult('Add', results));
    }

    // Get
    {
      List<int> results = [];
      for (var doc in _docs) {
        await add(doc);
      }
      final stopwatch = Stopwatch()..start();
      for (var doc in _docs) {
        final getDoc = get(doc);
        if (getDoc is Future) {
          await getDoc;
        }
      }
      stopwatch.stop();
      print('$name Get: ${stopwatch.elapsedMilliseconds}');
      results.add(stopwatch.elapsedMilliseconds);
      await reset();
      allRuns.add(TestResult('Get', results));
    }

    // Delete
    // for (var i = 0; i < 10; i++)
    {
      final results = <int>[];
      for (var doc in _docs) {
        await add(doc);
      }
      final stopwatch = Stopwatch()..start();
      for (var doc in _docs) {
        final removeDoc = remove(doc);
        if (removeDoc is Future) await removeDoc;
      }
      stopwatch.stop();
      print('$name Delete: ${stopwatch.elapsedMilliseconds}');
      results.add(stopwatch.elapsedMilliseconds);
      await reset();
      allRuns.add(TestResult('Delete', results));
    }

    return allRuns;
  }
}
