import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user_model.dart';
import 'models/note_model.dart';
import 'models/productivity_model.dart';

import 'page/about_app_page.dart';
import 'page/edit_profile_page.dart';
import 'page/profile_page.dart';
import 'page/splash_screen.dart';
import 'page/login_page.dart';
import 'page/register_page.dart';
import 'page/onboarding_page.dart';
import 'page/dashboard_page.dart';
import 'page/note_page.dart';
import 'page/productivity_page.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ✅ Register adapter
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(ProductivityModelAdapter());

  // ✅ Open boxes
  await Hive.openBox<UserModel>('users');
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<ProductivityModel>('productivity');
  await Hive.openBox('sessionBox'); // ✅ Wajib untuk login session

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/about': (context) => const AboutAppPage(),
            '/edit_profile': (context) => const EditProfilePage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/dashboard': (context) => const DashboardPage(),
            '/note': (context) => const NotePage(),
            '/productivity': (context) => const ProductivityPage(),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    );
  }
}
