import '../models/app_user.dart';
import '../widgets/floating_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/home/home_page.dart'; // Trang Home
import '../screens/search/search_page.dart'; // Trang Search
import '../screens/book/book_page.dart'; // Trang đặt lịch khám
import '../screens/history/history_page.dart'; // Trang History
import '../screens/profile/profile_page.dart'; // Trang Profile

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.account});
  final AppUser? account;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Danh sách các widget tương ứng với từng trang
  List<Widget> get _widgetOptions => <Widget>[
        HomePage(
            account: widget.account,
            onFindClinics: () => _onItemTapped(1),
            onBook: () => _onItemTapped(2)), // Trang Home
        const SearchPage(), // Trang Search
        const BookPage(), // Trang đặt lịch khám
        const HistoryPage(), // Trang History
        ProfilePage(account: widget.account), // Trang Profile
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF5F6F7),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F7),
        extendBody: true,
        body: SizedBox.expand(
            child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300), // Thời gian hoạt ảnh
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            alignment: Alignment.topLeft,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild
            ],
          ),
          child: _widgetOptions[_selectedIndex], // Hiển thị trang tương ứng
        )),
        bottomNavigationBar: FloatingNavigation(
            selectedIndex: _selectedIndex, onSelected: _onItemTapped),
      ),
    );
  }
}
