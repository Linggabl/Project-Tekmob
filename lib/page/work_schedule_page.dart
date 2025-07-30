import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/work_schedule_model.dart';

class WorkSchedulePage extends StatefulWidget {
  const WorkSchedulePage({super.key});

  @override
  State<WorkSchedulePage> createState() => _WorkSchedulePageState();
}

class _WorkSchedulePageState extends State<WorkSchedulePage> {
  late Box<WorkScheduleModel> workBox;
  late Box sessionBox;

  final TextEditingController activityController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  List<WorkScheduleModel> userWorks = [];

  @override
  void initState() {
    super.initState();
    _loadWorks();
  }

  Future<void> _loadWorks() async {
    workBox = await Hive.openBox<WorkScheduleModel>('workSchedule');
    sessionBox = await Hive.openBox('sessionBox');
    final currentUserEmail = sessionBox.get('currentUserId');

    setState(() {
      userWorks =
          workBox.values.where((w) => w.userEmail == currentUserEmail).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  Future<void> _addWork() async {
    final currentUserEmail = sessionBox.get('currentUserId');

    final newWork = WorkScheduleModel(
      day: DateFormat.EEEE().format(selectedDate),
      time: timeController.text.trim(),
      activity: activityController.text.trim(),
      userEmail: currentUserEmail,
      date: selectedDate,
    );

    await workBox.add(newWork);
    activityController.clear();
    timeController.clear();
    selectedDate = DateTime.now();
    _loadWorks();
  }

  Future<void> _editWork(WorkScheduleModel work) async {
    work.day = DateFormat.EEEE().format(selectedDate);
    work.time = timeController.text.trim();
    work.activity = activityController.text.trim();
    work.date = selectedDate;
    await work.save();
    _loadWorks();
  }

  void _showAddDialog() {
    selectedDate = DateTime.now();
    activityController.clear();
    timeController.clear();
    _showWorkDialog(isEdit: false);
  }

  void _showEditDialog(WorkScheduleModel work) {
    selectedDate = work.date;
    activityController.text = work.activity;
    timeController.text = work.time;
    _showWorkDialog(isEdit: true, work: work);
  }

  void _showWorkDialog({required bool isEdit, WorkScheduleModel? work}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Jam'),
            ),
            TextField(
              controller: activityController,
              decoration: const InputDecoration(labelText: 'Kegiatan'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
                  ),
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
              if (activityController.text.trim().isNotEmpty &&
                  timeController.text.trim().isNotEmpty) {
                if (isEdit && work != null) {
                  await _editWork(work);
                } else {
                  await _addWork();
                }
                if (context.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWork(int index) async {
    final work = userWorks[index];
    await work.delete();
    _loadWorks();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kerja'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: userWorks.isEmpty
          ? const Center(child: Text('Belum ada jadwal kerja.'))
          : ListView.builder(
              itemCount: userWorks.length,
              itemBuilder: (context, index) {
                final work = userWorks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '${DateFormat('EEEE, dd MMM yyyy').format(work.date)} - ${work.time}',
                    ),
                    subtitle: Text(work.activity),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(work),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWork(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
