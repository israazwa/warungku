import 'package:flutter/material.dart';

void customAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  String confirmText = 'Ya',
  String cancelText = 'Batal',
  Color iconColor = Colors.orange,
  IconData icon = Icons.warning_amber_outlined,
}) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 48.0),
                SizedBox(height: 12.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.0, color: Colors.black54),
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: iconColor,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(cancelText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
