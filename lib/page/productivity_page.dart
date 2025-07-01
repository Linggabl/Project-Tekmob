import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager_project_tekmob/models/productivity_model.dart';

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage> {
  late Box<ProductivityModel> productivityBox;
  late Box sessionBox;

  final TextEditingController taskController = TextEditingController();
  List<ProductivityModel> userTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    productivityBox = await Hive.openBox<ProductivityModel>('productivity');
    sessionBox = await Hive.openBox('sessionBox');

    final currentUserId = sessionBox.get('currentUserId');

    setState(() {
      userTasks = productivityBox.values
          .where((task) => task.userId == currentUserId)
          .toList();
    });
  }

  Future<void> _addTask() async {
    final currentUserId = sessionBox.get('currentUserId');

    final newTask = ProductivityModel(
      task: taskController.text,
      isCompleted: false,
      userId: currentUserId,
    );

    await productivityBox.add(newTask);
    taskController.clear();
    _loadTasks();
  }

  Future<void> _toggleTask(int index) async {
    final task = userTasks[index];
    task.isCompleted = !task.isCompleted;
    await task.save();
    _loadTasks();
  }

  Future<void> _deleteTask(int index) async {
    await userTasks[index].delete();
    _loadTasks();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: taskController,
          decoration: const InputDecoration(labelText: 'Tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              taskController.clear();
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _addTask();
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productivity Tasks')),
      body: userTasks.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: userTasks.length,
              itemBuilder: (context, index) {
                final task = userTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      task.task,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () => _toggleTask(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
