import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/format_number.dart';
import '../databases/db_helper.dart';
import '../models/transaksi_with_detail.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  final DbHelper db = DbHelper();
  List<TransaksiWithDetail> _riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final result = await db.getAllTransaksi();

    setState(() {
      _riwayat = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _riwayat.isEmpty
        ? Center(
          child: Text(
            'Belum ada data transaksi',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        )
        : ListView.builder(
          padding: EdgeInsets.all(12),
          physics: BouncingScrollPhysics(),
          itemCount: _riwayat.length,
          itemBuilder: (context, index) {
            final transaksi = _riwayat[index];

            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Tanggal dan Total
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.orange[600],
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd MMMM yyyy HH:mm',
                              'id',
                            ).format(DateTime.parse(transaksi.tanggal)),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            formatRupiah(transaksi.total.toInt()),
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    // Daftar Item (maksimal 2)
                    Column(
                      children: [
                        ...transaksi.items.take(2).map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  '${item.qty}x ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.namaMakanan,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Text(
                                  formatRupiah(item.subtotal.toInt()),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        // Tambahkan indikator jika ada lebih dari 2 item
                        if (transaksi.items.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: GestureDetector(
                              onTap: () {
                                // nanti diisi buka halaman detail
                                // Navigator.push(...);
                              },
                              child: Text(
                                '+${transaksi.items.length - 2} item lainnya',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Divider(height: 24),

                    // Footer Total & Kasir
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.grey[600]),
                        SizedBox(width: 6),
                        Text(
                          'Kasir: ${transaksi.kasir}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          formatRupiah(transaksi.total.toInt()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}
