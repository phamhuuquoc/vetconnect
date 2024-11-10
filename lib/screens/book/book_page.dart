import 'package:flutter/material.dart';

class BookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Màu nền trắng
      child: Center(
        child: Text(
          'Book Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
