# Flutter Web Storage Benchmarks

Bechmarking of different storage libraries on Flutter Web. For more information, see the blog [post](https://dillonnys.com/flutter-web-storage-benchmarks/).

![Benchmark Results](https://dillonnys.com/images/storage/benchmark_results.png)

| Library | Engine | Add (ms) | Get (ms) | Delete (ms) |
| ------- | ------ | -------- | -------- | ----------- |
| [Hive](https://pub.dev/packages/hive) | IndexedDB | 489 | 0 | 5 |
| [SQLite](https://sql.js.org/#/)* | In-Mem | 27 | 7 | 0 |
| [Sembast](https://pub.dev/packages/sembast_web) | IndexedDB | 614 | 9 | 90 |
| [Loki](https://github.com/techfort/LokiJS)* | IndexedDB | 115 | 1 | 1 |
| [Shared Preferences](https://pub.dev/packages/shared_preferences) | LocalStorage | 2 | 0 | 1 | 

\* Uses native JS library via interop.