import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 1)
class NoteModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime createdAt;

  NoteModel({
    required this.title,
    required this.content,
    required this.userId,
    required this.category,
    required this.createdAt,
  });
}
