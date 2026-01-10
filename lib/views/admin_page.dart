import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin/list_makanan_page.dart';
import 'admin/tambah_stok_page.dart';
import 'admin/favourite_page.dart';
import 'admin/kelola_user_page.dart';
import 'history/riwayat_transaksi_page.dart';
import '../components/custom_appbar.dart';
import '../components/custom_bottom_nav.dart';
import '../services/api_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  String? username;

  final List<Widget> _pages = const [
    ListMakananPage(),
    FavouritePage(),
    TambahStokPage(),
    RiwayatTransaksiPage(),
    KelolaUserPage(),
  ];

  final List<String> _titles = const [
    'List Makanan',
    'Favorite',
    'Tambah Stok',
    'Riwayat Transaksi',
    'Kelola Kasir',
  ];

  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.favorite,
    Icons.add_box,
    Icons.history,
    Icons.people,
  ];

  final List<String> _labels = [
    'Makanan',
    'Favorite',
    'Stok',
    'Riwayat',
    'Kasir',
  ];
  
  void initState() {
    super.initState();
    ApiService().syncMakananOnce();
    _loadUser();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => username = prefs.getString('username'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: _titles[_selectedIndex],
        username: '$username',
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        icons: _icons,
        labels: _labels,
      ),
    );
  }
}
