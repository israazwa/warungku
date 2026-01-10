import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/format_number.dart';
import '../../databases/db_helper.dart';
import '../../models/transaksi_with_detail.dart';
import 'detail_transaksi.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  State<RiwayatTransaksiPage> createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  final DbHelper db = DbHelper();
  List<TransaksiWithDetail> _riwayat = [];
  List<TransaksiWithDetail> _filteredRiwayat = [];
  bool _isLoading = true;
  String _selectedFilter = 'Hari ini';
  int _totalPendapatan = 0;
  String _makananTerlaris = '-';

  final List<String> _filters = [
    'Semua',
    'Hari ini',
    'Kemarin',
    '7 Hari terakhir',
    'Sebulan terakhir',
    '6 Bulan terakhir',
    'Setahun terakhir',
  ];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final result = await db.getAllTransaksi();

    setState(() {
      _riwayat = result;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    DateTime? startDate;
    List<TransaksiWithDetail> filtered = [];

    if (_selectedFilter == 'Semua') {
      filtered = _riwayat;
    } else if (_selectedFilter == 'Kemarin') {
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      filtered =
          _riwayat.where((trx) {
            final trxDate = DateTime.parse(trx.tanggal);
            return trxDate.year == yesterday.year &&
                trxDate.month == yesterday.month &&
                trxDate.day == yesterday.day;
          }).toList();
    } else {
      switch (_selectedFilter) {
        case 'Hari ini':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case '7 Hari terakhir':
          startDate = now.subtract(Duration(days: 7));
          break;
        case 'Sebulan terakhir':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case '6 Bulan terakhir':
          startDate = DateTime(now.year, now.month - 6, now.day);
          break;
        case 'Setahun terakhir':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }
    }

    if (startDate != null) {
      filtered =
          _riwayat
              .where((trx) => DateTime.parse(trx.tanggal).isAfter(startDate!))
              .toList();
    }

    // hitung total pendapatan
    double total = filtered.fold(0, (sum, trx) => sum + trx.total);
    String terlaris = db.getMakananTerlaris(filtered);

    setState(() {
      _filteredRiwayat = filtered;
      _totalPendapatan = total.toInt();
      _makananTerlaris = terlaris;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedFilter,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.teal[800]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.teal[800]!,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.black54),
                                labelText: 'Filter Waktu',
                                prefixIcon: Icon(Icons.filter_alt),
                              ),
                              items:
                                  _filters
                                      .map(
                                        (filter) => DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedFilter = val);
                                  _applyFilter();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 10),

                          // tombol untuk menampilkan semua transaksi
                          IconButton(
                            onPressed: () {
                              setState(() => _selectedFilter = 'Semua');
                              _loadRiwayat(); // tampilkan semua transaksi
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.teal[800],
                              size: 30,
                            ),
                            tooltip: 'Reset Filter',
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Pendapatan:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            formatRupiah(_totalPendapatan.toInt()),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Makanan Terlaris:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            _makananTerlaris,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredRiwayat.isEmpty
                      ? Center(
                        child: Text(
                          'Tidak ada transaksi pada periode ini',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(12),
                        physics: BouncingScrollPhysics(),
                        itemCount: _filteredRiwayat.length,
                        itemBuilder: (context, index) {
                          final transaksi = _filteredRiwayat[index];

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => DetailTransaksiPage(
                                        transaksi: transaksi,
                                      ),
                                ),
                              );
                            },
                            child: Card(
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: Colors.teal[600],
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            DateFormat(
                                              'dd MMMM yyyy HH:mm',
                                              'id',
                                            ).format(
                                              DateTime.parse(transaksi.tanggal),
                                            ),
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
                                            color: Colors.teal[50],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            formatRupiah(
                                              transaksi.total.toInt(),
                                            ),
                                            style: TextStyle(
                                              color: Colors.teal[800],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Column(
                                      children: [
                                        ...transaksi.items.take(2).map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${item.qty}x ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.teal[700],
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
                                                  formatRupiah(
                                                    item.subtotal.toInt(),
                                                  ),
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
                                        if (transaksi.items.length > 2)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              '+${transaksi.items.length - 2} item lainnya',
                                              style: TextStyle(
                                                color: Colors.teal,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Divider(height: 24),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 18,
                                          color: Colors.grey[600],
                                        ),
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
                                            color: Colors.teal[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
  }
}
