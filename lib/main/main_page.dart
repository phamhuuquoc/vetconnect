import 'package:flutter/material.dart';
import '../screens/home/home_page.dart'; // Trang Home
import '../screens/search/search_page.dart'; // Trang Search
import '../screens/book/book_page.dart'; // Trang đặt lịch khám
import '../screens/history/history_page.dart'; // Trang History
import '../screens/profile/profile_page.dart'; // Trang Profile

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
              _buildBottomNavItem(
                icon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              // Icon và chữ chú thích cho Search
              _buildBottomNavItem(
                icon: Icons.search,
                label: 'Search',
                index: 1,
              ),
              const SizedBox(width: 48), // Khoảng trống cho FloatingActionButton
              // Icon và chữ chú thích cho History
              _buildBottomNavItem(
                icon: Icons.history,
                label: 'History',
                index: 3,
              ),
              // Icon và chữ chú thích cho Profile
              _buildBottomNavItem(
                icon: Icons.person,
                label: 'Profile',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng các item trong Bottom Navigation Bar
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        _onItemTapped(index); // Chuyển đến trang tương ứng
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? const Color(0xFF1F41BB) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? const Color(0xFF1F41BB) : Colors.black54,
            ),
          ),
          Container(
            color: _selectedIndex == index ? const Color(0xFFF5F6F7) : Colors.transparent,
            height: 4,
            width: 40,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainPage(), // Khởi chạy MainPage
  ));
}
