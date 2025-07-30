import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/models/sleep_log_model.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  late Box<SleepLogModel> sleepBox;
  late Box sessionBox;
  List<SleepLogModel> userSleeps = [];

  @override
  void initState() {
    super.initState();
    _initBoxes();
  }

  Future<void> _initBoxes() async {
    sleepBox = await Hive.openBox<SleepLogModel>('sleepLogs');
    sessionBox = await Hive.openBox('sessionBox');
    await _loadSleeps();
  }

  Future<void> _loadSleeps() async {
    final currentUserEmail = sessionBox.get('currentUserId');
    if (!mounted) return;
    setState(() {
      userSleeps =
          sleepBox.values.where((s) => s.userEmail == currentUserEmail).toList()
            ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  String _durationText(SleepLogModel log) {
    final duration = log.wakeTime.difference(log.sleepTime);
    return '${duration.inHours} jam ${duration.inMinutes.remainder(60)} menit';
  }

  Future<void> _showSleepDialog({SleepLogModel? log}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        DateTime selectedDate = log?.date ?? DateTime.now();
        TimeOfDay sleepTime = log != null
            ? TimeOfDay.fromDateTime(log.sleepTime)
            : const TimeOfDay(hour: 22, minute: 0);
        TimeOfDay wakeTime = log != null
            ? TimeOfDay.fromDateTime(log.wakeTime)
            : const TimeOfDay(hour: 6, minute: 0);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                log != null ? 'Edit Data Tidur' : 'Tambah Data Tidur',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Jam Tidur: ${sleepTime.format(dialogContext)}',
                    ),
                    trailing: const Icon(Icons.bedtime),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: sleepTime,
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          sleepTime = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Jam Bangun: ${wakeTime.format(dialogContext)}',
                    ),
                    trailing: const Icon(Icons.alarm),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: dialogContext,
                        initialTime: wakeTime,
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          wakeTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, {
                      'date': selectedDate,
                      'sleepTime': sleepTime,
                      'wakeTime': wakeTime,
                    });
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      final selectedDate = result['date'] as DateTime;
      final sleepTime = result['sleepTime'] as TimeOfDay;
      final wakeTime = result['wakeTime'] as TimeOfDay;
      final currentUserEmail = sessionBox.get('currentUserId');

      final sleepDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        sleepTime.hour,
        sleepTime.minute,
      );

      final wakeDateTime =
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            wakeTime.hour,
            wakeTime.minute,
          ).isBefore(sleepDateTime)
          ? sleepDateTime
                .add(const Duration(days: 1))
                .copyWith(hour: wakeTime.hour, minute: wakeTime.minute)
          : DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              wakeTime.hour,
              wakeTime.minute,
            );

      if (log != null) {
        log.date = selectedDate;
        log.sleepTime = sleepDateTime;
        log.wakeTime = wakeDateTime;
        await log.save();
      } else {
        final newSleep = SleepLogModel(
          date: selectedDate,
          sleepTime: sleepDateTime,
          wakeTime: wakeDateTime,
          userEmail: currentUserEmail,
        );
        await sleepBox.add(newSleep);
      }

      await _loadSleeps();
    }
  }

  Future<void> _deleteSleep(int index) async {
    final log = userSleeps[index];
    await log.delete();
    await _loadSleeps();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: userSleeps.isEmpty
          ? const Center(child: Text('Belum ada data tidur.'))
          : ListView.builder(
              itemCount: userSleeps.length,
              itemBuilder: (context, index) {
                final log = userSleeps[index];
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
                      DateFormat('EEEE, dd MMM yyyy').format(log.date),
                    ),
                    subtitle: Text(
                      'Tidur: ${DateFormat.Hm().format(log.sleepTime)}\n'
                      'Bangun: ${DateFormat.Hm().format(log.wakeTime)}\n'
                      'Durasi: ${_durationText(log)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showSleepDialog(log: log),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSleep(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSleepDialog(),
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
