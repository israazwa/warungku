import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:warungku/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warungku',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      home: LoginPage(),
    );
  }

  ThemeData _buildTheme(brightness) {
    var baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.orange, // warna kursor
        selectionColor: Colors.orange[100], // warna blok saat nge select
        selectionHandleColor: Colors.orange, // warna titik pegangan blok teks
      )
    );
  }
}
