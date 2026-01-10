import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/hash_helper.dart';
import '../models/makanan.dart';
import '../models/transaksi.dart';
import '../models/transaksi_detail.dart';
import '../models/users.dart';
import '../models/transaksi_with_detail.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper.internal();
  factory DbHelper() => _instance;
  DbHelper.internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'warungku.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE makanan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            daerah TEXT,
            harga DOUBLE,
            stok INTEGER,
            deskripsi TEXT,
            gambar TEXT
          )
        ''');

        await db.execute('''
            CREATE TABLE transaksi (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tanggal TEXT,
              total DOUBLE,
              kasir_id INTEGER,
              FOREIGN KEY (kasir_id) REFERENCES users(id)
            )
          ''');

        await db.execute('''
            CREATE TABLE transaksi_detail (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              transaksi_id INTEGER,
              makanan_id INTEGER,
              qty INTEGER,
              subtotal DOUBLE,
              FOREIGN KEY (transaksi_id) REFERENCES transaksi(id),
              FOREIGN KEY (makanan_id) REFERENCES makanan(id)
            )
          ''');

        await db.execute('''
            CREATE TABLE favourite (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              makanan_id INTEGER UNIQUE,
              FOREIGN KEY (makanan_id) REFERENCES makanan(id)
            )
          ''');

        await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              password TEXT,
              role TEXT
            )
          ''');

        await db.insert('users', {
          'username': 'admin',
          'password': hashPassword('admin'),
          'role': 'admin',
        });
      },
    );
  }

  // =================== MAKANAN ========================= //
  // Menambahkan makanan
  Future<int> insertMakanan(Makanan makanan) async {
    final dbClient = await db;
    return await dbClient.insert('makanan', makanan.toMap());
  }

  // Mengupdate makanan
  Future<int> updateMakanan(Makanan makanan) async {
    final dbClient = await db;
    return await dbClient.update(
      'makanan',
      makanan.toMap(),
      where: 'id = ?',
      whereArgs: [makanan.id],
    );
  }

  // Menghapus makanan
  Future<int> deleteMakanan(int id) async {
    final dbClient = await db;
    return await dbClient.delete(
      'makanan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menampilkan semua makanan
  Future<List<Makanan>> getAllMakanan() async {
    final dbClient = await db;
    final result = await dbClient.query('makanan');
    return result.map((e) => Makanan.fromMap(e)).toList();
  }

  Future<Makanan?> getMakananById(int id) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'makanan',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Makanan.fromMap(result.first) : null;
  }

  Future<void> tambahStok(int makananId, int jumlah) async {
    final dbClient = await db;

    final result = await dbClient.query(
      'makanan',
      columns: ['stok'],
      where: 'id = ?',
      whereArgs: [makananId],
    );
    if (result.isNotEmpty) {
      final stokSekarang = result.first['stok'] as int;
      final stokBaru = stokSekarang + jumlah;

      await dbClient.update(
        'makanan',
        {'stok': stokBaru},
        where: 'id = ?',
        whereArgs: [makananId],
      );
    }
  }

  // ================= FAVOURITE ========================= //
  // Cek favourite
  Future<bool> isFavourite(int makananId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'favourite',
      where: 'makanan_id = ?',
      whereArgs: [makananId],
    );
    return result.isNotEmpty;
  }

  // Tambah ke favourite
  Future<void> insertFavourite(int makananId) async {
    final dbClient = await db;
    await dbClient.insert('favourite', {'makanan_id': makananId});
  }

  // Hapus dari favourite
  Future<void> deleteFavourite(int makananId) async {
    final dbClient = await db;
    await dbClient.delete(
      'favourite',
      where: 'makanan_id = ?',
      whereArgs: [makananId],
    );
  }

  // Menampilkan makanan favourite
  Future<List<Makanan>> getFavouriteMakanan() async {
    final dbClient = await db;
    final result = await dbClient.rawQuery('''
        SELECT makanan.* FROM favourite
        JOIN makanan ON favourite.makanan_id = makanan.id
      '''); // makanan.* mengambil semua kolom dari makanan saja
    return result.map((e) => Makanan.fromMap(e)).toList();
  }

  // =================== TRANSAKSI ========================= //
  // Insert transaksi dan detail (otomatis)
  Future<void> insertTransaksi(
    Transaksi transaksi,
    List<TransaksiDetail> details,
  ) async {
    final dbClient = await db;

    await dbClient.transaction((txn) async {
      int transaksiId = await txn.insert('transaksi', transaksi.toMap());
      for (var detail in details) {
        await txn.insert(
          'transaksi_detail',
          detail.copyWith(transaksi_id: transaksiId).toMap(),
        );

        // kurangi stok
        await txn.rawUpdate(
          '''
        UPDATE makanan SET stok = stok - ? WHERE id = ?
        ''',
          [detail.qty, detail.makanan_id],
        );
      }
    });
  }

  // Menampilkan semua transaksi
  Future<List<TransaksiWithDetail>> getAllTransaksi() async {
    final dbClient = await db;

    final transaksiList = await dbClient.rawQuery('''
      SELECT t.id, t.tanggal, t.total, u.username as kasir
      FROM transaksi t
      JOIN users u ON t.kasir_id = u.id
      ORDER BY t.tanggal DESC
    ''');

    List<TransaksiWithDetail> riwayat = [];

    for (var trx in transaksiList) {
      final detailList = await dbClient.rawQuery(
        '''
          SELECT td.qty, td.subtotal, m.nama as namaMakanan
          FROM transaksi_detail td
          JOIN makanan m ON td.makanan_id = m.id
          WHERE td.transaksi_id = ?
        ''',
        [trx['id']],
      );
      List<TransaksiDetailWithNama> detailItems =
          detailList.map((d) {
            return TransaksiDetailWithNama(
              qty: d['qty'] as int,
              subtotal: (d['subtotal'] as num).toDouble(),
              namaMakanan: d['namaMakanan'] as String,
            );
          }).toList();

      riwayat.add(TransaksiWithDetail(
        id: trx['id'] as int,
        tanggal: trx['tanggal'] as String,
        total: trx['total'] as double,
        kasir: trx['kasir'] as String,
        items: detailItems,
      ));
    }
    return riwayat;
  }

  // Menampilkan makanan terlaris
  String getMakananTerlaris(List<TransaksiWithDetail> data) {
    Map<String, int> makananCounter = {};

    for (var trx in data) {
      for (var item in trx.items) {
        makananCounter[item.namaMakanan] =
            (makananCounter[item.namaMakanan] ?? 0) + item.qty;
      }
    }

    if (makananCounter.isEmpty) return '-';

    final sorted = makananCounter.entries.toList()..sort((a, b) => b.value.compareTo(a.value)); // descending
    return sorted.first.key;
  }

  // ===================== LOGIN ======================== //
  Future<Users?> login(String username, String password) async {
    final dbClient = await db;
    final hashedPassword = hashPassword(password);

    final result = await dbClient.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );
    if (result.isNotEmpty) {
      return Users.fromMap(result.first);
    }
    return null;
  }

  // ===================== USERS ====================== //
  // Menambah data kasir
  Future<void> insertUsers(Users users) async {
    final dbClient = await db;
    await dbClient.insert(
      'users',
      {
        'username': users.username,
        'password': hashPassword(users.password),
        'role': users.role,
      },
    );
  }

  Future<bool> isUsernameTaken(String username, {int? excludeId}) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'users',
      where: excludeId != null ? 'username = ? AND id != ?' : 'username = ?',
      whereArgs: excludeId != null ? [username, excludeId] : [username],
      // jika excludeId ada artinya sedang ada dalam mode edit, maka akan mengecek username yang sama namun tidak dengan id dia sendiri.
      // Jika excludeId tidak ada artinya sedang dalam mode tambah, maka hanya mengecek username yang sama saja
    );
    return result.isNotEmpty;
  }

  // Ambil data user
  Future<List<Users>> getAllUsers() async {
    final dbClient = await db;
    final result = await dbClient.query('users');
    return result.map((e) => Users.fromMap(e)).toList();
  }

  // Hapus data user
  Future<void> deleteUsers(int id) async {
    final dbClient = await db;
    await dbClient.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Ubah data user
  Future<void> updateUsers(Users users) async {
    final dbClient = await db;
    await dbClient.update(
      'users',
      {
        'username': users.username,
        'password': hashPassword(users.password),
        'role': users.role,
      },
      where: 'id = ?',
      whereArgs: [users.id],
    );
  }
}
