class Makanan {
  final int? id;
  final String nama;
  final String daerah;
  final double harga;
  final int stok;
  final String deskripsi;
  final String gambar;

  Makanan({
    this.id,
    required this.nama,
    required this.daerah,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.gambar,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'daerah': daerah,
    'harga': harga,
    'stok': stok,
    'deskripsi': deskripsi,
    'gambar': gambar
  };

  factory Makanan.fromMap(Map<String, dynamic> map) => Makanan(
    id: map['id'],
    nama: map['nama'],
    daerah: map['daerah'],
    harga: (map['harga'] as num).toDouble(),
    stok: (map['stok'] as num).toInt(),
    deskripsi: map['deskripsi'],
    gambar: map['gambar']
  );

  Makanan copyWith({
    int? id,
    String? nama,
    String? daerah,
    double? harga,
    int? stok,
    String? deskripsi,
    String? gambar,
  }) {
    return Makanan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      daerah: daerah ?? this.daerah,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      deskripsi: deskripsi ?? this.deskripsi,
      gambar: gambar ?? this.gambar
    );
  }
}
