import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppFooter({
    Key? key,
    this.currentIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF004d40),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
