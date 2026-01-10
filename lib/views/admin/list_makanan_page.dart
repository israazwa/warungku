import 'dart:io';
import 'package:flutter/material.dart';
import 'package:warungku/components/custom_alert_dialog.dart';
import 'package:warungku/components/custom_snackbar.dart';
import 'package:warungku/components/makanan_form_dialog.dart';
import '../../databases/db_helper.dart';
import '../../models/makanan.dart';
import '../../utils/format_number.dart';

class ListMakananPage extends StatefulWidget {
  const ListMakananPage({super.key});

  @override
  State<ListMakananPage> createState() => _ListMakananPageState();
}

class _ListMakananPageState extends State<ListMakananPage> {
  final DbHelper db = DbHelper();

  List<Makanan> _makananList = [];
  Set<int> _favouriteMakananIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMakanan();
  }

  Future<void> _loadMakanan() async {
    final result = await db.getAllMakanan();
    final favouriteMakananIds = await db.getFavouriteMakanan();

    setState(() {
      _makananList = result;
      _isLoading = false;
      _favouriteMakananIds = favouriteMakananIds.map((e) => e.id!).toSet();
    });
  }

  Future<void> _saveMakanan(Makanan? makanan) async {
    await showDialog(
      context: context,
      builder: (context) {
        return MakananFormDialog(
          makanan: makanan,
          onSubmit: (newMakanan) async {
            if (makanan == null) {
              await db.insertMakanan(newMakanan);
              showCustomSnackbar(context: context, message: 'Makanan berhasil ditambah!');
            } else {
              await db.updateMakanan(newMakanan);
              showCustomSnackbar(context: context, message: 'Makanan berhasil diperbarui!');
            }
            await _loadMakanan();
          },
        );
      },
    );
  }

  Future<void> _deleteMakanan(Makanan makanan) async {
    await db.deleteMakanan(makanan.id!);
    await _loadMakanan();
    showCustomSnackbar(
      context: context,
      message: '${makanan.nama} berhasil dihapus',
    );
  }

  void _showDeleteConfirmation(Makanan makanan) {
    customAlertDialog(
      context: context,
      title: 'Hapus Makanan',
      content: 'Anda yakin ingin menghapus ${makanan.nama}?',
      onConfirm: () => _deleteMakanan(makanan),
    );
  }

  Future<void> _toggleFavouriteMakanan(Makanan makanan) async {
    if (_favouriteMakananIds.contains(makanan.id)) {
      await db.deleteFavourite(makanan.id!);
      _favouriteMakananIds.remove(makanan.id!);
      showCustomSnackbar(
        context: context,
        message: '${makanan.nama} berhasil dihapus dari daftar favorit',
      );
    } else {
      await db.insertFavourite(makanan.id!);
      _favouriteMakananIds.add(makanan.id!);
      showCustomSnackbar(
        context: context,
        message: '${makanan.nama} berhasil ditambahkan ke daftar favorit',
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _makananList.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data makanan',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      itemCount: _makananList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2 / 3, // Biar lebih tinggi
                      ),
                      itemBuilder: (context, index) {
                        final m = _makananList[index];
                        return _buildMakananCard(m);
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _saveMakanan(null),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ));
  }

  Widget _buildMakananCard(Makanan makanan) {
    final isFav = _favouriteMakananIds.contains(makanan.id);
    final isNetworkImage = makanan.gambar.startsWith('http');

    return InkWell(
      onTap: () => _showDetailMakanan(makanan),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: isNetworkImage
                        ? Image.network(
                            makanan.gambar,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          )
                        : Image.file(
                            File(makanan.gambar),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              );
                            },
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          makanan.nama,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black45, blurRadius: 2),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          makanan.daerah,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (makanan.stok == 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Stok Habis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _saveMakanan(makanan);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(makanan);
                        } else if (value == 'favorite') {
                          _toggleFavouriteMakanan(makanan);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'favorite',
                          child: Text(isFav ? 'Hapus Favorit' : 'Tambah Favorit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatRupiah(makanan.harga),
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            makanan.stok > 0 ? 'Stok: ${makanan.stok}' : '-',
                            style: TextStyle(
                              color:
                                  makanan.stok > 0
                                      ? Colors.black87
                                      : Colors.red,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailMakanan(Makanan makanan) {
    final isNetworkImage = makanan.gambar.startsWith('http');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isNetworkImage
                      ? Image.network(
                          makanan.gambar,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 60),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        )
                      : Image.file(
                          File(makanan.gambar),
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        makanan.nama,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        makanan.daerah,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Divider(),
                      Text(
                        makanan.deskripsi,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Tutup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(100, 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
