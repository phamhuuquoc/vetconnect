import 'package:flutter/material.dart';
import 'login_page.dart'; // Import trang đăng nhập

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Hiển thị trang đăng nhập
    );
  }
}
