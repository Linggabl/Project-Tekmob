import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/note_model.dart';

class NoteDetailPage extends StatelessWidget {
  final NoteModel note;

  const NoteDetailPage({super.key, required this.note});

  Color getCategoryColor(String category) {
    switch (category) {
      case 'Kuliah':
        return Colors.deepPurple;
      case 'Kerja':
        return Colors.green;
      case 'Lainnya':
        return Colors.grey;
      case 'Pribadi':
      default:
        return Colors.blue;
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Kuliah':
        return Icons.school;
      case 'Kerja':
        return Icons.work;
      case 'Lainnya':
        return Icons.folder;
      case 'Pribadi':
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            Row(
              children: [
                Icon(
                  getCategoryIcon(note.category),
                  color: getCategoryColor(note.category),
                ),
                const SizedBox(width: 8),
                Text(
                  note.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: getCategoryColor(note.category),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              note.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Tanggal
            Text(
              '📅 ${DateFormat.yMMMMd().format(note.createdAt)}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            // Isi Catatan
            Text(
              note.content,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
