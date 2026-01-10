import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../databases/db_helper.dart';
import '../../models/makanan.dart';
import '../../components/custom_snackbar.dart';

class TambahStokPage extends StatefulWidget {
  const TambahStokPage({super.key});

  @override
  State<TambahStokPage> createState() => _TambahStokPageState();
}

class _TambahStokPageState extends State<TambahStokPage> {
  final DbHelper db = DbHelper();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Makanan> _makananList = [];
  Makanan? _selectedMakanan;
  final TextEditingController _stockController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMakanan();
  }

  Future<void> _loadMakanan() async {
    final result = await db.getAllMakanan();
    setState(() {
      _makananList = result;
      _isLoading = false;
    });
  }

  Future<void> _tambahStok() async {
    if (_formKey.currentState!.validate()) {
      final jumlahTambahStok = int.tryParse(_stockController.text) ?? 0; // Mengonversi ke integer dari string (klo gk bisa akan null)
      await db.tambahStok(_selectedMakanan!.id!, jumlahTambahStok);

      if (!mounted) return; // mounted fungsinya mengecek apakah widget masih ada sblm memanggil setState()

      // Ambil ulang data makanan terbaru dari database
      final updatedMakananList = await db.getAllMakanan();
      final updatedSelectedMakanan = updatedMakananList.firstWhere((makanan) => makanan.id == _selectedMakanan!.id);

      setState(() {
        _makananList = updatedMakananList;
        _selectedMakanan = updatedSelectedMakanan;
        _stockController.clear();
      });

      // tutup keyboard dan hapus focus
      FocusScope.of(context).unfocus();

      showCustomSnackbar(
        context: context,
        message: 'Stok ${_selectedMakanan!.nama} berhasil ditambahkan!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _makananList.isEmpty
        ? Center(
          child: Text(
            'Tidak ada data makanan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        )
        : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Lottie.asset('assets/lottie/inventory.json', height: 150),
              SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<Makanan>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Makanan',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(Icons.fastfood),
                          ),
                          value: _selectedMakanan,
                          items:
                              _makananList.map((makanan) {
                                return DropdownMenuItem(
                                  value: makanan,
                                  child: Text(
                                    '${makanan.nama} - ${makanan.stok} stok',
                                  ),
                                );
                              }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedMakanan = val);
                          },
                          validator:
                              (val) => val == null ? 'Pilih makanan dulu' : null,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Stok Tambahan',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.orange),
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(Icons.add_box_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Jumlah stok tidak boleh kosong';
                            }

                            if (int.tryParse(val) == null) {
                              return 'Jumlah stok harus berupa angka';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _tambahStok,
                          icon: Icon(Icons.save_alt_rounded),
                          label: Text('Tambah Stok'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
