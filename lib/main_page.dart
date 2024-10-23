import 'package:flutter/material.dart';
import 'home_page.dart'; // Nhập trang Home
import 'search_page.dart'; // Nhập trang Search
import 'book_page.dart'; // Nhập trang Book (trang đặt lịch khám)
import 'history_page.dart'; // Nhập trang History
import 'profile_page.dart'; // Nhập trang Profile

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Danh sách các widget tương ứng với từng trang
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),       // Trang Home
    SearchPage(),     // Trang Search
    BookPage(),       // Trang đặt lịch khám
    HistoryPage(),    // Trang History
    ProfilePage(),    // Trang Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300), // Thời gian hoạt ảnh
          child: _widgetOptions[_selectedIndex], // Hiển thị trang tương ứng
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 2; // Chuyển đến trang Book
            });
          },
          backgroundColor: const Color(0xFF1F41BB),
          child: const Icon(Icons.add, color: Colors.white), // Icon dấu cộng màu trắng
          shape: const CircleBorder(),
          elevation: 6.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFFF5F6F7), // Màu nền của thanh menu
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Icon và chữ chú thích cho Home
              GestureDetector(
                onTap: () {
                  _onItemTapped(0); // Chuyển đến trang Home
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.home,
                      color: _selectedIndex == 0 ? const Color(0xFF1F41BB) : Colors.black54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: _selectedIndex == 0 ? const Color(0xFF1F41BB) : Colors.black54,
                      ),
                    ),
                    Container(
                      color: _selectedIndex == 0 ? const Color(0xFFF5F6F7) : Colors.transparent,
                      height: 4,
                      width: 40,
                    ),
                  ],
                ),
              ),
              // Icon và chữ chú thích cho Search
              GestureDetector(
                onTap: () {
                  _onItemTapped(1); // Chuyển đến trang Search
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search,
                      color: _selectedIndex == 1 ? const Color(0xFF1F41BB) : Colors.black54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: _selectedIndex == 1 ? const Color(0xFF1F41BB) : Colors.black54,
                      ),
                    ),
                    Container(
                      color: _selectedIndex == 1 ? const Color(0xFFF5F6F7) : Colors.transparent,
                      height: 4,
                      width: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Khoảng trống cho FloatingActionButton
              // Icon và chữ chú thích cho History
              GestureDetector(
                onTap: () {
                  _onItemTapped(3); // Chuyển đến trang History
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      color: _selectedIndex == 3 ? const Color(0xFF1F41BB) : Colors.black54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'History',
                      style: TextStyle(
                        color: _selectedIndex == 3 ? const Color(0xFF1F41BB) : Colors.black54,
                      ),
                    ),
                    Container(
                      color: _selectedIndex == 3 ? const Color(0xFFF5F6F7) : Colors.transparent,
                      height: 4,
                      width: 40,
                    ),
                  ],
                ),
              ),
              // Icon và chữ chú thích cho Profile
              GestureDetector(
                onTap: () {
                  _onItemTapped(4); // Chuyển đến trang Profile
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      color: _selectedIndex == 4 ? const Color(0xFF1F41BB) : Colors.black54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: _selectedIndex == 4 ? const Color(0xFF1F41BB) : Colors.black54,
                      ),
                    ),
                    Container(
                      color: _selectedIndex == 4 ? const Color(0xFFF5F6F7) : Colors.transparent,
                      height: 4,
                      width: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainPage(), // Khởi chạy MainPage
  ));
}
