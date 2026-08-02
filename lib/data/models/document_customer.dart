/// Model untuk satu file TDP dalam array tdp_files.
class TdpFile {
  final String path;
  final String uploadedAt;
  final int size;

  TdpFile({required this.path, required this.uploadedAt, this.size = 0});

  factory TdpFile.fromJson(Map<String, dynamic> json) {
    int parseVal(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return TdpFile(
      path: json['path'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
      size: parseVal(json['size']),
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'uploaded_at': uploadedAt,
    'size': size,
  };
}

/// Model untuk tabel document_customers.
class DocumentCustomer {
  final int id;
  final int customerId;
  final String? kopSurat;
  final int kopSuratSize;
  final String? dataUmum;
  final int dataUmumSize;
  final List<TdpFile> tdpFiles;
  final DateTime? tdpMasaBerlaku;
  final String? statusTdp;
  final String? permohonanSkrb;
  final String? permohonanRekom;
  final String? alamatPermohonan;
  final String? bidangUsaha;
  final String? alamatLengkap;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentCustomer({
    required this.id,
    required this.customerId,
    this.kopSurat,
    this.kopSuratSize = 0,
    this.dataUmum,
    this.dataUmumSize = 0,
    this.tdpFiles = const [],
    this.tdpMasaBerlaku,
    this.statusTdp,
    this.permohonanSkrb,
    this.permohonanRekom,
    this.alamatPermohonan,
    this.bidangUsaha,
    this.alamatLengkap,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentCustomer.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return DocumentCustomer(
      id: parseInt(json['id']),
      customerId: parseInt(json['customer_id']),
      kopSurat: (json['kop_surat_file'] ?? json['kop_surat'])?.toString(),
      kopSuratSize: parseInt(json['kop_surat_size']),
      dataUmum: (json['data_umum_file'] ?? json['data_umum'])?.toString(),
      dataUmumSize: parseInt(json['data_umum_size']),
      tdpFiles: json['tdp_files'] != null && json['tdp_files'] is List
          ? (json['tdp_files'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => TdpFile.fromJson(e))
              .toList()
          : [],
      tdpMasaBerlaku: json['tdp_masa_berlaku'] != null
          ? DateTime.tryParse(json['tdp_masa_berlaku'].toString())?.toLocal()
          : null,
      statusTdp: json['status_tdp']?.toString(),
      permohonanSkrb: json['permohonan_skrb']?.toString(),
      permohonanRekom: json['permohonan_rekom']?.toString(),
      alamatPermohonan: json['alamat_permohonan']?.toString(),
      bidangUsaha: json['bidang_usaha']?.toString(),
      alamatLengkap: json['alamat_lengkap']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
