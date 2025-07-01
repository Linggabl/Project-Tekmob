import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:email_validator/email_validator.dart';
import 'package:task_manager_project_tekmob/models/user_model.dart';
import 'package:task_manager_project_tekmob/page/dashboard_page.dart';
import 'package:task_manager_project_tekmob/page/register_page.dart';
import 'package:task_manager_project_tekmob/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _keepSignedIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final userBox = await Hive.openBox<UserModel>('users');
    final sessionBox = await Hive.openBox('sessionBox');

    final email = emailController.text.trim();
    final password = passwordController.text;

    final user = userBox.values.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => UserModel(name: '', email: '', password: ''),
    );

    if (!mounted) return;

    if (user.email.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Email atau password salah!')),
        );
    } else {
      await sessionBox.put('currentUserId', user.email);
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

        return Scaffold(
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            foregroundColor: textColor,
            title: const Text("Login"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Bersihkan input, keyboard, dan snackbar
                emailController.clear();
                passwordController.clear();
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(context).clearSnackBars();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.pop(context);
                });
              },
            ),
            actions: [
              IconButton(
                tooltip: "Toggle Dark Mode",
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                onPressed: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            Image.asset(
                              'assets/login_image.png',
                              height: MediaQuery.of(context).size.height * 0.13,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Selamat Datang Kembali 👋",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Masuk untuk melanjutkan aktivitasmu",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Email",
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: emailController,
                              cursorColor: textColor,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Masukkan email',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: inputFillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: textColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  EmailValidator.validate(value ?? '')
                                  ? null
                                  : 'Email tidak valid',
                            ),
                            const SizedBox(height: 12),

                            // Password Field
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Password",
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              cursorColor: textColor,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Masukkan password',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: inputFillColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: textColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) =>
                                  (value != null && value.isNotEmpty)
                                  ? null
                                  : 'Password tidak boleh kosong',
                            ),
                            const SizedBox(height: 6),

                            // Checkbox
                            CheckboxListTile(
                              value: _keepSignedIn,
                              onChanged: (value) {
                                setState(() {
                                  _keepSignedIn = value ?? false;
                                });
                              },
                              activeColor: textColor,
                              checkColor: isDark ? Colors.black : Colors.white,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Ingat akun saya",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Login Button
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  loginUser();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size.fromHeight(48),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Google login (opsional)
                            TextButton.icon(
                              onPressed: () {},
                              icon: Image.asset(
                                'assets/google_icon.png',
                                height: 20,
                                width: 20,
                              ),
                              label: Text(
                                'Login dengan Google',
                                style: TextStyle(color: textColor),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color.fromARGB(255, 230, 230, 230),
                                minimumSize: const Size.fromHeight(48),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Link to register
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Belum punya akun? Daftar di sini",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
