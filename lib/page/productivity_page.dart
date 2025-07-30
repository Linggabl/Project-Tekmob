import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/productivity_model.dart';

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage>
    with SingleTickerProviderStateMixin {
  late Box<ProductivityModel> productivityBox;
  late Box sessionBox;
  late TabController _tabController;

  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  DateTime? selectedDeadline;

  List<ProductivityModel> userTasks = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.trim().toLowerCase();
      });
    });
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    productivityBox = await Hive.openBox<ProductivityModel>('productivity');
    sessionBox = await Hive.openBox('sessionBox');

    final currentUserEmail = sessionBox.get('currentUserId');

    setState(() {
      userTasks =
          productivityBox.values
              .where((task) => task.userEmail == currentUserEmail)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _addTask() async {
    final currentUserEmail = sessionBox.get('currentUserId');

    final newTask = ProductivityModel(
      task: taskController.text.trim(),
      isCompleted: false,
      userEmail: currentUserEmail,
      createdAt: DateTime.now(),
      deadline: selectedDeadline,
    );

    await productivityBox.add(newTask);
    taskController.clear();
    selectedDeadline = null;
    _loadTasks();
  }

  Future<void> _toggleTask(int index) async {
    final task = _filteredTasks()[index];
    task.isCompleted = !task.isCompleted;
    await task.save();
    _loadTasks();
  }

  Future<void> _deleteTask(int index) async {
    final task = _filteredTasks()[index];
    await task.delete();
    _loadTasks();
  }

  void _showTaskDetailDialog(ProductivityModel task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Detail Tugas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.task,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Dibuat: ${DateFormat.yMMMd().format(task.createdAt)}'),
            if (task.deadline != null)
              Text('Deadline: ${DateFormat.yMMMd().format(task.deadline!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    selectedDeadline = null;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Tambah Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: 'Nama tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Deadline: '),
                  const SizedBox(width: 8),
                  Text(
                    selectedDeadline != null
                        ? DateFormat.yMMMd().format(selectedDeadline!)
                        : 'Belum dipilih',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDeadline = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                taskController.clear();
                selectedDeadline = null;
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (taskController.text.trim().isNotEmpty) {
                  await _addTask();
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(ProductivityModel task) {
    final TextEditingController editController = TextEditingController(
      text: task.task,
    );
    DateTime? editDeadline = task.deadline;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Edit Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(
                  labelText: 'Nama tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Deadline: '),
                  const SizedBox(width: 8),
                  Text(
                    editDeadline != null
                        ? DateFormat.yMMMd().format(editDeadline!)
                        : 'Belum dipilih',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: builderContext,
                        initialDate: editDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          editDeadline = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editController.text.trim().isNotEmpty) {
                  task.task = editController.text.trim();
                  task.deadline = editDeadline;
                  await task.save();
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    _loadTasks();
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  List<ProductivityModel> _filteredTasks() {
    List<ProductivityModel> filtered;

    if (_tabController.index == 1) {
      filtered = userTasks.where((t) => !t.isCompleted).toList();
    } else if (_tabController.index == 2) {
      filtered = userTasks.where((t) => t.isCompleted).toList();
    } else {
      filtered = userTasks;
    }

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) => task.task.toLowerCase().contains(searchQuery))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredTasks();
    final completed = userTasks.where((t) => t.isCompleted).length;
    final progress = userTasks.isEmpty ? 0.0 : completed / userTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Produktivitas'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF5C6BC0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF5C6BC0),
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari tugas...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_tabController.index == 1 && userTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("Progress Hari Ini: "),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.green,
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tugas',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];
                      return Card(
                        color: isDark
                            ? (task.isCompleted
                                  ? const Color(0xFF2E2E48)
                                  : Colors.grey[850])
                            : (task.isCompleted
                                  ? const Color(0xFFEAEAF6)
                                  : Colors.white),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          onTap: _tabController.index == 1
                              ? () => _showTaskDetailDialog(task)
                              : null,
                          title: Text(
                            task.task,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : (task.isCompleted
                                        ? Colors.grey
                                        : Colors.black),
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dibuat: ${DateFormat.yMMMd().format(task.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                              ),
                              if (task.deadline != null)
                                Text(
                                  'Deadline: ${DateFormat.yMMMd().format(task.deadline!)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              if (_tabController.index == 0)
                                Text(
                                  'Status: ${task.isCompleted ? 'Selesai' : 'Belum Selesai'}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : const Color(0xFFF9B549),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: _tabController.index == 0
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showEditTaskDialog(task),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteTask(index),
                                    ),
                                  ],
                                )
                              : null,
                          leading: _tabController.index == 1
                              ? Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTask(index),
                                  activeColor: Colors.green,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
