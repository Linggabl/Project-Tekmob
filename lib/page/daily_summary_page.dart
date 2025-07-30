import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/productivity_model.dart';
import 'package:task_manager_project_tekmob/models/sleep_log_model.dart';
import 'package:task_manager_project_tekmob/models/work_schedule_model.dart';

class DailySummaryPage extends StatefulWidget {
  const DailySummaryPage({super.key});

  @override
  State<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends State<DailySummaryPage> {
  DateTime selectedDate = DateTime.now();
  List<SleepLogModel> filteredSleepLogs = [];
  List<ProductivityModel> filteredTasks = [];
  List<WorkScheduleModel> filteredWorks = [];

  @override
  void initState() {
    super.initState();
    _loadFilteredData();
  }

  Future<void> _loadFilteredData() async {
    final sessionBox = await Hive.openBox('sessionBox');
    final currentUserEmail = sessionBox.get('currentUserId');

    // Load Sleep
    final sleepBox = await Hive.openBox<SleepLogModel>('sleepLogs');
    final allSleep = sleepBox.values.where((log) {
      return log.userEmail == currentUserEmail &&
          isSameDay(log.date, selectedDate);
    }).toList();

    // Load Productivity
    final productivityBox = await Hive.openBox<ProductivityModel>(
      'productivity',
    );
    final allTasks = productivityBox.values.where((task) {
      return task.userEmail == currentUserEmail &&
          isSameDay(task.createdAt, selectedDate);
    }).toList();

    // Load Work
    final workBox = await Hive.openBox<WorkScheduleModel>('workSchedule');
    final allWorks = workBox.values.where((work) {
      return work.userEmail == currentUserEmail &&
          isSameDay(work.date, selectedDate);
    }).toList();

    setState(() {
      filteredSleepLogs = allSleep;
      filteredTasks = allTasks;
      filteredWorks = allWorks;
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _loadFilteredData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Sleep', style: Theme.of(context).textTheme.titleMedium),
            if (filteredSleepLogs.isEmpty)
              const Text('Tidak ada data tidur hari ini.\n')
            else
              ...filteredSleepLogs.map((log) {
                final duration = log.wakeTime.difference(log.sleepTime);
                return ListTile(
                  title: Text(DateFormat('EEEE, dd MMM yyyy').format(log.date)),
                  subtitle: Text(
                    'Tidur: ${DateFormat.Hm().format(log.sleepTime)}\n'
                    'Bangun: ${DateFormat.Hm().format(log.wakeTime)}\n'
                    'Durasi: ${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit',
                  ),
                );
              }),

            const SizedBox(height: 16),
            Text(
              'Productivity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (filteredTasks.isEmpty)
              const Text('Tidak ada tugas hari ini.\n')
            else
              ...filteredTasks.map((task) {
                return ListTile(
                  title: Text(task.task),
                  subtitle: Text(
                    'Status: ${task.isCompleted ? "Selesai" : "Belum"}\n'
                    'Dibuat: ${DateFormat.yMMMd().format(task.createdAt)}',
                  ),
                );
              }),

            const SizedBox(height: 16),
            Text('Work', style: Theme.of(context).textTheme.titleMedium),
            if (filteredWorks.isEmpty)
              const Text('Tidak ada jadwal kerja hari ini.\n')
            else
              ...filteredWorks.map((work) {
                return ListTile(
                  title: Text(work.activity),
                  subtitle: Text(
                    '${work.day} • ${work.time}\nTanggal: ${DateFormat.yMMMd().format(work.date)}',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
