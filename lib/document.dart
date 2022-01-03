@JS()

import 'package:hive/hive.dart';
import 'package:js/js.dart';

part 'document.g.dart';

@HiveType(typeId: 0)
class Document {
  const Document({
    required this.id,
    required this.data,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final double data;
}

@JS()
@anonymous
class JSDocument implements Document {
  external factory JSDocument({
    String id,
    double data,
  });

  @override
  external String get id;

  @override
  external double get data;
}
