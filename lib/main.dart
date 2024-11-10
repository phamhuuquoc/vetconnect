import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main/main_page.dart'; // Trang Main
import 'auth/login_page.dart'; // Trang Login
import 'auth/signup_page.dart'; // Trang Signup
import 'auth/forgot_password_page.dart'; // Trang Quên mật khẩu
import 'screens/home/home_page.dart'; // Trang Home
import 'screens/book/book_page.dart'; // Trang Đặt lịch khám
import 'screens/profile/profile_page.dart'; // Trang Profile
import 'screens/history/history_page.dart'; // Trang History
import 'screens/search/search_page.dart'; // Trang Search

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const VetConnectApp());
}

class VetConnectApp extends StatelessWidget {
  const VetConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Route đầu tiên khi khởi động ứng dụng
      routes: {
        '/': (context) => const MainPage(), // Route chính
        '/login': (context) => LoginPage(), // Route đăng nhập
        '/signup': (context) => const SignupPage(), // Route đăng ký
        '/forgot_password': (context) => const ForgotPasswordPage(), // Route quên mật khẩu
        '/home': (context) =>  HomePage(), // Route trang Home
        '/book': (context) =>  BookPage(), // Route trang đặt lịch khám
        '/profile': (context) =>  ProfilePage(), // Route trang Profile
        '/history': (context) =>  HistoryPage(), // Route trang History
        '/search': (context) =>  SearchPage(), // Route trang Search
      },
    );
  }
}
