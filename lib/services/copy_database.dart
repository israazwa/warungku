import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

Future<void> copyDatabaseFromAsset() async {
  // Lokasi target penyimpanan database di device
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, 'warung_nusantara.db');

  // Hapus jika database sudah ada
  if (await File(path).exists()) {
    try {
      await File(path).delete();
      print('Database lama dihapus.');
    } catch (e) {
      print('Gagal menghapus database lama: $e');
    }
  }

  // Buat folder jika belum ada
  try {
    await Directory(dirname(path)).create(recursive: true);
  } catch (_) {}

  // Copy database baru dari assets
  try {
    ByteData data = await rootBundle.load('assets/db/warung_nusantara.db');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
    print('Database baru berhasil disalin ke $path');
  } catch (e) {
    print('Gagal menyalin database: $e');
  }
}
