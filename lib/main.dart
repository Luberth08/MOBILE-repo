import 'package:flutter/material.dart';
import 'screens/email_login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/password_login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Repo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EmailLoginScreen(),
        '/verify': (context) => const OtpScreen(),
        '/password': (context) => const PasswordLoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
