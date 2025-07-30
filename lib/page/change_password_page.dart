import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user_model.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isOldPassVisible = false;
  bool _isNewPassVisible = false;
  bool _isConfirmPassVisible = false;

  void _changePassword() async {
    final sessionBox = await Hive.openBox('sessionBox');
    final usersBox = await Hive.openBox<UserModel>('users');

    final currentUserId = sessionBox.get('currentUserId');
    final userIndex = usersBox.values.toList().indexWhere(
      (user) => user.email == currentUserId,
    );

    if (userIndex == -1) return;

    final user = usersBox.getAt(userIndex);

    if (_oldPassController.text != user?.password) {
      _showMessage('Password lama salah');
      return;
    }

    if (_newPassController.text != _confirmPassController.text) {
      _showMessage('Konfirmasi password tidak cocok');
      return;
    }

    if (_newPassController.text.isEmpty) {
      _showMessage('Password baru tidak boleh kosong');
      return;
    }

    user?.password = _newPassController.text;
    await usersBox.putAt(userIndex, user!);

    if (!mounted) return;
    _showMessage('Password berhasil diubah');
    Navigator.pop(context);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPasswordField(
              label: 'Password Lama',
              controller: _oldPassController,
              isVisible: _isOldPassVisible,
              onToggle: () =>
                  setState(() => _isOldPassVisible = !_isOldPassVisible),
            ),
            _buildPasswordField(
              label: 'Password Baru',
              controller: _newPassController,
              isVisible: _isNewPassVisible,
              onToggle: () =>
                  setState(() => _isNewPassVisible = !_isNewPassVisible),
            ),
            _buildPasswordField(
              label: 'Konfirmasi Password',
              controller: _confirmPassController,
              isVisible: _isConfirmPassVisible,
              onToggle: () => setState(
                () => _isConfirmPassVisible = !_isConfirmPassVisible,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Perubahan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
