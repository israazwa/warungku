import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/format_number.dart';
import '../../models/transaksi_with_detail.dart';

class DetailTransaksiPage extends StatelessWidget {
  final TransaksiWithDetail transaksi;

  const DetailTransaksiPage({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Umum
            _buildInfoTile(
              icon: Icons.calendar_today,
              label: 'Tanggal & Waktu',
              value: DateFormat('dd MMMM yyyy - HH:mm', 'id')
                  .format(DateTime.parse(transaksi.tanggal)),
            ),
            const SizedBox(height: 12),
            _buildInfoTile(
              icon: Icons.person,
              label: 'Nama Kasir',
              value: transaksi.kasir,
            ),
            const SizedBox(height: 24),

            Text(
              'Detail Pesanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transaksi.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = transaksi.items[index];
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.qty}x ${item.namaMakanan}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      formatRupiah(item.subtotal.toInt()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatRupiah(transaksi.total.toInt()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.teal[600]),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
