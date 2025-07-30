import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class ChangeNamePage extends StatefulWidget {
  const ChangeNamePage({super.key});

  @override
  State<ChangeNamePage> createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void _changeName() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      _showMessage('Nama baru tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    final sessionBox = await Hive.openBox('sessionBox');
    final usersBox = await Hive.openBox<UserModel>('users');
    final currentUserId = sessionBox.get('currentUserId');

    final userIndex = usersBox.values.toList().indexWhere(
      (user) => user.email == currentUserId,
    );

    if (userIndex != -1) {
      final user = usersBox.getAt(userIndex);
      user?.name = newName;
      await usersBox.putAt(userIndex, user!);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
    _showMessage('Nama berhasil diubah');
    Navigator.pop(context);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF5C6BC0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Nama'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Baru',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                height: 48, // Lebih kecil seperti di gambar kamu
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changeName,
                  icon: const Icon(Icons.save, size: 18),
                  label: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 14),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10, // lebih tipis
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
