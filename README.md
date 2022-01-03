# Flutter Web Storage Benchmarks

Bechmarking of different storage libraries on Flutter Web. For more information, see the blog [post](https://dillonnys.com/flutter-web-storage-benchmarks/).

![Benchmark Results](https://dillonnys.com/images/storage/benchmark_results.png)

| Library | Engine | Add (ms) | Get (ms) | Delete (ms) |
| ------- | ------ | -------- | -------- | ----------- |
| [Hive](https://pub.dev/packages/hive) | IndexedDB | 470 | 0 | 2 |
| [SQLite](https://sql.js.org/#/)* | In-Mem | 29 | 10 | 0 |
| [Sembast](https://pub.dev/packages/sembast_web) | IndexedDB | 546 | 3 | 461 |
| [Loki](https://github.com/techfort/LokiJS)* | IndexedDB | 91 | 2 | 0 |
| [Shared Preferences](https://pub.dev/packages/shared_preferences) | LocalStorage | 1 | 0 | 2 | 

\* Uses native JS library via interop.