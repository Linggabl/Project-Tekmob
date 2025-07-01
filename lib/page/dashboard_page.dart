import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:task_manager_project_tekmob/main.dart';
import 'package:task_manager_project_tekmob/models/user_model.dart';
import 'package:task_manager_project_tekmob/page/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String currentUserName = '';
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sessionBox = await Hive.openBox('sessionBox');
    final usersBox = await Hive.openBox<UserModel>('users');

    String? currentUserId = sessionBox.get('currentUserId');
    final currentUser = usersBox.values.firstWhere(
      (user) => user.email == currentUserId,
      orElse: () => UserModel(name: '', email: '', password: ''),
    );

    setState(() {
      currentUserName = currentUser.name;
      profileImagePath = currentUser.profileImagePath;
    });
  }

  void _logout() async {
    final sessionBox = await Hive.openBox('sessionBox');
    await sessionBox.delete('currentUserId');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _buildTaskCard({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateFormat('d, MMMM yyyy').format(DateTime.now());
    const primaryColor = Color(0xFF5C6BC0);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: Drawer(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50),
                        Center(
                          child: CircleAvatar(
                            radius: 34,
                            backgroundImage:
                                profileImagePath != null &&
                                    profileImagePath!.isNotEmpty
                                ? FileImage(File(profileImagePath!))
                                : const AssetImage('assets/profile_avatar.png')
                                      as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Hi, $currentUserName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                '/edit_profile',
                              );
                              _loadUserData(); // refresh data
                            },
                            icon: const Icon(Icons.edit, size: 13),
                            label: const Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                          ),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          secondary: Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          value: isDark,
                          onChanged: (value) {
                            themeNotifier.value = value
                                ? ThemeMode.dark
                                : ThemeMode.light;
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.settings,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          title: Text(
                            'Pengaturan',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Fitur Pengaturan belum tersedia.",
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          title: Text(
                            'Tentang Aplikasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context); // tutup drawer
                            Navigator.pushNamed(
                              context,
                              '/about',
                            ); // buka halaman about
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 1,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text(
            today,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.calendar_today,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Task'),
              Tab(text: 'In-progress'),
              Tab(text: 'Completed'),
            ],
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello $currentUserName!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Have a nice day.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildTaskCard(
                          icon: Icons.edit,
                          title: 'Catatan',
                          backgroundColor: primaryColor,
                          onTap: () => Navigator.pushNamed(context, '/note'),
                        ),
                        _buildTaskCard(
                          icon: Icons.timer,
                          title: 'Productivity',
                          backgroundColor: Colors.orange,
                          onTap: () =>
                              Navigator.pushNamed(context, '/productivity'),
                        ),
                        _buildTaskCard(
                          icon: Icons.work,
                          title: 'Work',
                          backgroundColor: Colors.blue,
                          onTap: () {},
                        ),
                        _buildTaskCard(
                          icon: Icons.bedtime,
                          title: 'Sleep',
                          backgroundColor: const Color(0xFFBA68C8),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                'Tugas yang sedang dikerjakan',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
            Center(
              child: Text(
                'Tugas yang sudah selesai',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
