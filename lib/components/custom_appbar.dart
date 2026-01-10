import 'package:flutter/material.dart';
import '../views/login_page.dart';
import 'custom_alert_dialog.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String username;

  CustomAppbar({required this.title, required this.username});

  void _showLogoutDialog(BuildContext context) {
    customAlertDialog(
      context: context,
      title: 'Logout Warning',
      content: 'Apakah $username yakin ingin logout?',
      onConfirm:
          () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.orange[700],
          fontWeight: FontWeight.w600,
          fontSize: 21,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, size: 30),
          tooltip: 'Logout Warning',
          onPressed: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // menentukan tinggi appbar (wajib diisi), defaultnya kToolbarHeight
}
