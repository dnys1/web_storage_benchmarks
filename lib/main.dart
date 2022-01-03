import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_storage_benchmarks/backends/common.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Storage Benchmarks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Web Storage Benchmarks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<Benchmark, List<TestResult>> _results = {
    for (var benchmark in Benchmark.all) benchmark: [],
  };
  List<Series<TestResult, String>> get scores => [
        for (var result in _results.entries)
          Series<TestResult, String>(
            id: result.key.name,
            seriesColor: result.key.color,
            data: result.value,
            domainFn: (TestResult result, _) => result.testName,
            measureFn: (TestResult result, _) =>
                _useLog ? result.logAverage : result.average,
            labelAccessorFn: (TestResult result, _) =>
                result.average.toStringAsFixed(0) + 'ms',
          ),
      ];
  NumericTickFormatterSpec get formatter =>
      BasicNumericTickFormatterSpec((val) {
        if (val == null) {
          return '0ms';
        }
        return (_useLog ? pow(10, val) : val).toStringAsFixed(0) + 'ms';
      });

  bool _runningBenchmarks = false;
  bool _benchmarksComplete = false;
  bool _useLog = true;

  static const maxWidth = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_benchmarksComplete)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Linear'),
                      Switch(
                        value: _useLog,
                        onChanged: (val) {
                          setState(() {
                            _useLog = val;
                          });
                        },
                      ),
                      const Text('Logarithmic'),
                    ],
                  ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: maxWidth),
                    child: ScoreChart(
                      results: scores,
                      formatter: formatter,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _runningBenchmarks
                      ? null
                      : () async {
                          setState(() {
                            _runningBenchmarks = true;
                          });
                          try {
                            for (var benchmark in Benchmark.all) {
                              final results = await benchmark.run();
                              setState(() {
                                _results[benchmark] = results;
                              });
                            }
                            setState(() {
                              _benchmarksComplete = true;
                              _runningBenchmarks = false;
                            });
                            // ignore: avoid_catches_without_on_clauses
                          } catch (e, st) {
                            print('Error: $e\n$st');
                          } finally {
                            for (var benchmark in Benchmark.all) {
                              benchmark.reset().ignore();
                            }
                          }
                        },
                  child: const Text('Run Benchmarks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreChart extends StatelessWidget {
  const ScoreChart({
    Key? key,
    required this.results,
    required this.formatter,
  }) : super(key: key);

  final List<Series<TestResult, String>> results;
  final NumericTickFormatterSpec formatter;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      results,
      animate: true,
      barGroupingType: BarGroupingType.grouped,
      behaviors: [SeriesLegend()],
      barRendererDecorator: BarLabelDecorator<String>(),
      domainAxis: const AxisSpec<String>(
        tickProviderSpec: StaticOrdinalTickProviderSpec([
          TickSpec('Add'),
          TickSpec('Get'),
          TickSpec('Delete'),
        ]),
      ),
      primaryMeasureAxis: NumericAxisSpec(
        tickFormatterSpec: formatter,
      ),
    );
  }
}
