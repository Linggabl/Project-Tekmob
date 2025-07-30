import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/note_model.dart';
import 'note_detail_page.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late Box<NoteModel> noteBox;
  late Box sessionBox;
  List<NoteModel> userNotes = [];
  List<NoteModel> filteredNotes = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'Semua';
  String selectedNoteCategory = 'Pribadi';

  final List<String> categories = [
    'Semua',
    'Pribadi',
    'Kuliah',
    'Kerja',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    noteBox = await Hive.openBox<NoteModel>('notes');
    sessionBox = await Hive.openBox('sessionBox');
    final currentUserId = sessionBox.get('currentUserId');

    final allNotes = noteBox.values
        .where((note) => note.userId == currentUserId)
        .toList();

    setState(() {
      userNotes = allNotes;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredNotes = userNotes.where((note) {
        final matchesCategory =
            selectedCategory == 'Semua' || note.category == selectedCategory;
        final matchesSearch =
            note.title.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            note.content.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> _addOrEditNote({NoteModel? existingNote, int? index}) async {
    final isEditing = existingNote != null;
    titleController.text = isEditing ? existingNote.title : '';
    contentController.text = isEditing ? existingNote.content : '';
    selectedNoteCategory = isEditing ? existingNote.category : 'Pribadi';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Isi'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedNoteCategory,
                items: categories.where((e) => e != 'Semua').map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedNoteCategory = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              contentController.clear();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.isEmpty || content.isEmpty) return;

              final currentUserId = sessionBox.get('currentUserId');

              if (isEditing && index != null) {
                final updatedNote = NoteModel(
                  title: title,
                  content: content,
                  userId: existingNote.userId,
                  category: selectedNoteCategory,
                  createdAt: existingNote.createdAt,
                );
                await existingNote.delete();
                await noteBox.putAt(index, updatedNote);
              } else {
                final newNote = NoteModel(
                  title: title,
                  content: content,
                  userId: currentUserId,
                  category: selectedNoteCategory,
                  createdAt: DateTime.now(),
                );
                await noteBox.add(newNote);
              }

              titleController.clear();
              contentController.clear();

              if (mounted) {
                Navigator.pop(context);
                _loadNotes();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(NoteModel note) async {
    await note.delete();
    _loadNotes();
  }

  Color getCategoryColor(String category, bool isDark) {
    if (isDark) {
      switch (category) {
        case 'Kuliah':
          return const Color(0xFF4527A0);
        case 'Kerja':
          return const Color(0xFF2E7D32);
        case 'Lainnya':
          return const Color(0xFF546E7A);
        case 'Pribadi':
        default:
          return const Color(0xFF1565C0);
      }
    } else {
      switch (category) {
        case 'Kuliah':
          return const Color(0xFFD1C4E9);
        case 'Kerja':
          return const Color(0xFFC8E6C9);
        case 'Lainnya':
          return const Color(0xFFCFD8DC);
        case 'Pribadi':
        default:
          return const Color(0xFFBBDEFB);
      }
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

  Widget _buildNoteCard(NoteModel note, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = getCategoryColor(note.category, isDark);
    final textColor = bgColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Card(
      color: bgColor,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: NoteDetailPage(note: note),
              ),
              transitionsBuilder: (_, animation, __, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(getCategoryIcon(note.category), color: textColor),
            const SizedBox(height: 4),
            Text(
              note.category,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        title: Text(
          note.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.content, style: TextStyle(color: textColor)),
            const SizedBox(height: 6),
            Text(
              '📅 ${DateFormat.yMMMMd().format(note.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withAlpha((0.7 * 255).toInt()),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textColor),
          onSelected: (value) {
            if (value == 'edit') {
              _addOrEditNote(existingNote: note, index: index);
            } else if (value == 'delete') {
              _deleteNote(note);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Saya'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: const InputDecoration(
                      hintText: 'Cari catatan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(child: Text('Tidak ada catatan'))
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(filteredNotes[index], index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
