import 'package:hive/hive.dart';

part 'work_schedule_model.g.dart';

@HiveType(typeId: 3)
class WorkScheduleModel extends HiveObject {
  @HiveField(0)
  String day;

  @HiveField(1)
  String time;

  @HiveField(2)
  String activity;

  @HiveField(3)
  String userEmail; // ✅ ganti dari userId

  @HiveField(4)
  DateTime date;

  WorkScheduleModel({
    required this.day,
    required this.time,
    required this.activity,
    required this.userEmail, // ✅ ganti dari userId
    required this.date,
  });
}
