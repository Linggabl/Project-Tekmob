import 'package:hive/hive.dart';

part 'productivity_model.g.dart';

@HiveType(typeId: 2)
class ProductivityModel extends HiveObject {
  @HiveField(0)
  String task;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String userId; // ← Tambahan penting

  ProductivityModel({
    required this.task,
    this.isCompleted = false,
    required this.userId,
  });
}
