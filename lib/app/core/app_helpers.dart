// File: lib/app/core/app_helpers.dart

/// Format ukuran file: jika < 1 MB ditulis dalam KB, jika >= 1 MB ditulis dalam MB.
String formatFileSize(dynamic bytesVal) {
  if (bytesVal == null) return '0 KB';
  int bytes = 0;
  if (bytesVal is int) {
    bytes = bytesVal;
  } else if (bytesVal is double) {
    bytes = bytesVal.toInt();
  } else {
    bytes = int.tryParse(bytesVal.toString()) ?? 0;
  }

  if (bytes <= 0) return '0 KB';

  const int kb = 1024;
  const int mb = 1024 * 1024;

  if (bytes >= mb) {
    double val = bytes / mb;
    String str = val.toStringAsFixed(2);
    if (str.endsWith('.00')) {
      str = str.substring(0, str.length - 3);
    } else if (str.endsWith('0')) {
      str = str.substring(0, str.length - 1);
    }
    return '$str MB';
  } else {
    double val = bytes / kb;
    String str = val.toStringAsFixed(1);
    if (str.endsWith('.0')) {
      str = str.substring(0, str.length - 2);
    }
    return '$str KB';
  }
}

/// Format tanggal menjadi d-m-Y H:m:s (dd-mm-yyyy HH:mm:ss).
String formatDateTime(dynamic dateVal) {
  if (dateVal == null) return '-';
  DateTime? dt;
  if (dateVal is DateTime) {
    dt = dateVal;
  } else if (dateVal is String) {
    dt = DateTime.tryParse(dateVal);
  }
  if (dt == null) return dateVal.toString();
  dt = dt.toLocal();
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final year = dt.year.toString();
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  final second = dt.second.toString().padLeft(2, '0');
  return '$day-$month-$year $hour:$minute:$second';
}

/// Daftar nama bulan dalam bahasa Indonesia (index 1 = Januari).
const List<String> kBulanIndonesia = [
  '',
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Format tanggal ke format Indonesia: "d MMMM yyyy" (contoh: 15 Agustus 2026).
String formatTanggalIndonesia(dynamic dateVal) {
  if (dateVal == null || dateVal == '-' || dateVal.toString().isEmpty) {
    return '-';
  }
  DateTime? dt;
  if (dateVal is DateTime) {
    dt = dateVal;
  } else if (dateVal is String) {
    dt = DateTime.tryParse(dateVal);
  }
  if (dt == null) return dateVal.toString();
  final day = dt.day;
  final month = (dt.month >= 1 && dt.month <= 12)
      ? kBulanIndonesia[dt.month]
      : '';
  final year = dt.year;
  return '$day $month $year'.trim();
}
