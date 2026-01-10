import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history/riwayat_transaksi_page.dart';
import 'kasir/transaksi_page.dart';
import '../components/custom_appbar.dart';
import '../components/custom_bottom_nav.dart';

class KasirHomePage extends StatefulWidget {
  const KasirHomePage({super.key});

  @override
  State<KasirHomePage> createState() => _KasirHomePageState();
}

class _KasirHomePageState extends State<KasirHomePage> {
  String? username;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TransaksiPage(),
    RiwayatTransaksiPage(),
  ];

  final List<String> _titles = const [
    'Transaksi Yuk!',
    'Riwayat Transaksi',
  ];

  final List<IconData> _icons = [
    Icons.shopping_cart,
    Icons.history
  ];

  final List<String> _labels = [
    'Transaksi',
    'Riwayat',
  ];
  
  void initState() {
    super.initState();
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
