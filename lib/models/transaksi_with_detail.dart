// Model helper untuk menampilkan data transaksi beserta detailnya pada UI
class TransaksiWithDetail {
  final int id;
  final String tanggal;
  final double total;
  final String kasir;
  final List<TransaksiDetailWithNama> items;

  TransaksiWithDetail({
    required this.id,
    required this.tanggal,
    required this.total,
    required this.kasir,
    required this.items,
  });
}

class TransaksiDetailWithNama {
  final String namaMakanan;
  final int qty;
  final double subtotal;

  TransaksiDetailWithNama({
    required this.namaMakanan,
    required this.qty,
    required this.subtotal,
  });
}