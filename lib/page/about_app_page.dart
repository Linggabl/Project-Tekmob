import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(child: Icon(Icons.task, size: 64, color: Colors.deepPurple)),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Task Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const Center(child: Text('Versi 1.0.0')),
            const SizedBox(height: 20),
            const Text(
              'Aplikasi untuk mencatat tugas, meningkatkan produktivitas, dan mengelola catatan harian Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Fitur Utama:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manajemen Catatan'),
            ),
            const ListTile(
              leading: Icon(Icons.timer),
              title: Text('Tracker Produktivitas'),
            ),
            const ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Mode Gelap & Terang'),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profil dan Pengaturan'),
            ),
            const Divider(height: 40),
            const Text(
              'Dikembangkan oleh:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Lingga Bangun Laksana', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              'Hubungi Saya:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('linggabl346@gmail.com'),
              onTap: () {
                _launchURL('mailto:linggabl346@gmail.com');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('@linggabgnl (Instagram)'),
              onTap: () {
                _launchURL('https://www.instagram.com/linggabgnl/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('linggabl (GitHub)'),
              onTap: () {
                _launchURL('https://github.com/linggabl');
              },
            ),
          ],
        ),
      ),
    );
  }
}
