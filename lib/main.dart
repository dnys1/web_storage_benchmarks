import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_storage_benchmarks/backends/common.dart';
import 'package:web_storage_benchmarks/backends/hive.dart';
import 'package:web_storage_benchmarks/backends/sembast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  final Map<String, List<TestResult>> _results = {
    for (var benchmark in Benchmark.all) benchmark.name: [],
  };
  List<Series<TestResult, String>> get scores => [
        for (var result in _results.entries)
          Series<TestResult, String>(
            id: result.key,
            data: result.value,
            domainFn: (TestResult result, _) => result.testName,
            measureFn: (TestResult result, _) =>
                _useLog ? result.logAverage : result.average,
          ),
      ];
  bool _runningBenchmarks = false;
  bool _benchmarksComplete = false;
  bool _useLog = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_benchmarksComplete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Lin'),
                    Switch(
                      value: _useLog,
                      onChanged: (val) {
                        setState(() {
                          _useLog = val;
                        });
                      },
                    ),
                    const Text('Log'),
                  ],
                ),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 600),
                  child: ScoreChart(results: scores),
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
                        for (var benchmark in Benchmark.all) {
                          final results = await benchmark.run();
                          setState(() {
                            _results[benchmark.name] = results;
                          });
                        }
                        setState(() {
                          _benchmarksComplete = true;
                          _runningBenchmarks = false;
                        });
                      },
                child: const Text('Run Benchmarks'),
              ),
            ],
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
  }) : super(key: key);

  final List<Series<TestResult, String>> results;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      results,
      animate: true,
      barGroupingType: BarGroupingType.grouped,
      domainAxis: const AxisSpec<String>(
        tickProviderSpec: StaticOrdinalTickProviderSpec([
          TickSpec('Add'),
          TickSpec('Get'),
          TickSpec('Delete'),
        ]),
      ),
    );
  }
}
