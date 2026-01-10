import 'package:intl/intl.dart';

String formatRupiah(num angka) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(angka);
}
