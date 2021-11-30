import 'package:hive/hive.dart';

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

  Map<String, Object> toJson() => {
        'id': id,
        'data': data,
      };
}
