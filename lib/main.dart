import 'package:flutter/material.dart';
import 'main_page.dart'; // Nhập MainPage để sử dụng
import 'login_page.dart'; // Nhập trang đăng nhập

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
      routes: {
        '/main': (context) => const MainPage(), // Đường dẫn đến MainPage
      },
    );
  }
}
