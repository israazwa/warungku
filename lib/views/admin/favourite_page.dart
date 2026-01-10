import 'package:flutter/material.dart';
import 'package:warungku/utils/format_number.dart';
import '../../databases/db_helper.dart';
import '../../models/makanan.dart';
import '../../components/custom_alert_dialog.dart';
import '../../components/custom_snackbar.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final DbHelper db = DbHelper();

  List<Makanan> _favouriteList = []; // List<Makanan> untuk menyimpan makanan favorit
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavourite();
  }

  Future<void> _loadFavourite() async {
    final result = await db.getFavouriteMakanan();

    setState(() {
      _favouriteList = result;
      _isLoading = false;
    });
  }

  Future<void> _removeFavourite(Makanan makanan) async {
    await db.deleteFavourite(makanan.id!);

    // refresh daftar favourite
    await _loadFavourite();
    showCustomSnackbar(context: context, message: '${makanan.nama} berhasil dihapus dari daftar favorit');
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _favouriteList.isEmpty
        ? Center(
          child: Text(
            'Belum ada data favorit',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        )
        : Padding(
          padding: EdgeInsets.all(12.0),
          child: ListView.separated(
            itemCount: _favouriteList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final makanan = _favouriteList[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    makanan.gambar,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: Colors.grey,
                        ),
                  ),
                ),
                title: Text(
                  makanan.nama,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  formatRupiah(makanan.harga),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Hapus Favorit',
                  onPressed: () => _showDeleteConfirmation(makanan), 
                ),
              );
            },
          ),
        );
  }

  void _showDeleteConfirmation(Makanan makanan) {
    customAlertDialog(
      context: context,
      title: 'Hapus Favorit',
      content: 'Anda yakin ingin menghapus ${makanan.nama} dari daftar favorit?',
      onConfirm: () => _removeFavourite(makanan),
    );
  }
}
