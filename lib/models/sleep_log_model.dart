import 'package:hive/hive.dart';

part 'sleep_log_model.g.dart';

@HiveType(typeId: 4)
class SleepLogModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  DateTime sleepTime;

  @HiveField(2)
  DateTime wakeTime;

  @HiveField(3)
  String userEmail; // ✅ ganti jadi email

  SleepLogModel({
    required this.date,
    required this.sleepTime,
    required this.wakeTime,
    required this.userEmail,
  });
}

