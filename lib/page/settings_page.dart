import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Ubah Nama'),
            onTap: () {
              Navigator.pushNamed(context, '/change_name');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ubah Password'),
            onTap: () {
              Navigator.pushNamed(context, '/change_password');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Ubah Email'),
            onTap: () {
              Navigator.pushNamed(context, '/change_email');
            },
          ),
        ],
      ),
    );
  }
}
