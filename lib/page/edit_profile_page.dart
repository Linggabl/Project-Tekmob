import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:task_manager_project_tekmob/main.dart';
import 'package:task_manager_project_tekmob/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? userEmail;
  File? _pickedImage;
  late Box<UserModel> usersBox;
  UserModel? currentUser;
  bool isImageChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData(); // refresh otomatis ketika kembali dari ubah email
  }

  Future<void> _loadUserData() async {
    final sessionBox = await Hive.openBox('sessionBox');
    userEmail = sessionBox.get('currentUserId');

    usersBox = await Hive.openBox<UserModel>('users');
    currentUser = usersBox.values.firstWhere(
      (user) => user.email == userEmail,
      orElse: () => UserModel(name: '', email: '', password: ''),
    );

    if (currentUser!.profileImagePath != null) {
      _pickedImage = File(currentUser!.profileImagePath!);
    }

    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Ambil dari Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text("Pilih dari Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
          isImageChanged = true;
        });
      }
    }
  }

  Future<void> _confirmAndSaveImage() async {
    final isDark = themeNotifier.value == ThemeMode.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: const Text("Konfirmasi"),
        content: const Text("Simpan perubahan foto profil?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final userIndex = usersBox.values.toList().indexWhere(
        (u) => u.email == userEmail,
      );

      if (userIndex != -1 && _pickedImage != null) {
        final updatedUser = UserModel(
          name: currentUser!.name,
          email: currentUser!.email,
          password: currentUser!.password,
          profileImagePath: _pickedImage!.path,
        );

        await usersBox.putAt(userIndex, updatedUser);
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  void _zoomImage() {
    final imageFile =
        _pickedImage ??
        (currentUser?.profileImagePath != null
            ? File(currentUser!.profileImagePath!)
            : null);

    if (imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text("Lihat Foto"),
              backgroundColor: themeNotifier.value == ThemeMode.dark
                  ? Colors.black
                  : Colors.white,
              foregroundColor: themeNotifier.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            ),
            body: Center(
              child: PhotoView(
                imageProvider: FileImage(imageFile),
                backgroundDecoration: BoxDecoration(
                  color: themeNotifier.value == ThemeMode.dark
                      ? Colors.black
                      : Colors.white,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
        actions: [
          if (isImageChanged)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: "Simpan Foto",
              onPressed: _confirmAndSaveImage,
            ),
        ],
      ),
      body: usersBox.isOpen
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _zoomImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : currentUser?.profileImagePath != null
                          ? FileImage(File(currentUser!.profileImagePath!))
                          : const AssetImage('assets/profile_avatar.png')
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text("Ganti Foto"),
                  ),
                  const SizedBox(height: 30),
                  _infoRow(
                    Icons.person,
                    "Nama",
                    currentUser?.name ?? '',
                    isDark,
                  ),
                  const SizedBox(height: 20),
                  _infoRow(
                    Icons.email,
                    "Email",
                    currentUser?.email ?? '',
                    isDark,
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: isDark ? Colors.white60 : Colors.black54),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
