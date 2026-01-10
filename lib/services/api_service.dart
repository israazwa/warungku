import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/makanan.dart';
import '../databases/db_helper.dart';

class ApiService {
  final DbHelper db = DbHelper();

  final String API_URL = 'https://6864c9325b5d8d03397e4646.mockapi.io/makanandaerah/api/nama';

  Future<void> fetchAndStoreMakanan() async {
    try {
      final response = await http.get(Uri.parse(API_URL));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        for (var item in data) {
          final makanan = Makanan.fromMap(item);
          await db.insertMakanan(makanan);
        }

        print('Data berhasi disimpan ke database');

      } else {
        print('Gagal fetch data dari API: ${response.statusCode}');
      }
    } catch(e) {
      print('Error: $e');
    }
  }

  Future<void> syncMakananOnce() async {
    final _db = await DbHelper().db;
    final existing = await _db.query('makanan');

    if (existing.isEmpty) {
      print('Database masih kosong, melakukan fetch data dari API...');
      await fetchAndStoreMakanan();
    } else {
      print('Data sudah ada di database, tidak perlu fetch data lagi');
    }
  }
}
