import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeIn;
  String title = "";
  String subtitle = "";
  final String fullTitle = "Task Manager";
  final String fullSubtitle = "Fokus. Selesai. Lebih Baik.";

  int titleIndex = 0;
  int subtitleIndex = 0;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    typeTitle();
    Future.delayed(const Duration(milliseconds: 1400), typeSubtitle);

    // Navigasi ke onboarding setelah 4 detik
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  void typeTitle() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (titleIndex < fullTitle.length) {
        setState(() {
          title += fullTitle[titleIndex];
          titleIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void typeSubtitle() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (subtitleIndex < fullSubtitle.length) {
        setState(() {
          subtitle += fullSubtitle[subtitleIndex];
          subtitleIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/login_image.png', height: 100),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  color: Colors.deepPurple[300],
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
