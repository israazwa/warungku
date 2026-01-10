class TransaksiDetail {
  final int? id;
  final int transaksi_id;
  final int makanan_id;
  final int qty;
  final double subtotal;

  TransaksiDetail({
    this.id,
    required this.transaksi_id,
    required this.makanan_id,
    required this.qty,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'transaksi_id': transaksi_id,
    'makanan_id': makanan_id,
    'qty': qty,
    'subtotal': subtotal,
  };

  factory TransaksiDetail.fromMap(Map<String, dynamic> map) {
    return TransaksiDetail(
      id: map['id'],
      transaksi_id: map['transaksi_id'],
      makanan_id: map['makanan_id'],
      qty: map['qty'],
      subtotal: map['subtotal'],
    );
  }

  TransaksiDetail copyWith({
    int? id,
    int? transaksi_id,
    int? makanan_id,
    int? qty,
    int? subtotal,
  }) {
    return TransaksiDetail(
      id: id ?? this.id,
      transaksi_id: transaksi_id ?? this.transaksi_id,
      makanan_id: makanan_id ?? this.makanan_id,
      qty: qty ?? this.qty,
      subtotal: subtotal?.toDouble() ?? this.subtotal,
    );
  }
}

