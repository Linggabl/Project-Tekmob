import 'package:hive/hive.dart';

part 'productivity_model.g.dart';

@HiveType(typeId: 2)
class ProductivityModel extends HiveObject {
  @HiveField(0)
  String task;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String userEmail; // ✅ ganti dari userId

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? deadline; // Optional deadline

  ProductivityModel({
    required this.task,
    this.isCompleted = false,
    required this.userEmail, // ✅ ganti dari userId
    required this.createdAt,
    this.deadline,
  });
}
