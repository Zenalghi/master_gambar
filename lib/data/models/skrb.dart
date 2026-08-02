// File: lib/data/models/skrb.dart

class SkrbHistoryItem {
  final int id;
  final int skrbId;
  final String fileName;
  final String storagePath;
  final int fileSize;
  final String createdAt;

  SkrbHistoryItem({
    required this.id,
    required this.skrbId,
    required this.fileName,
    required this.storagePath,
    required this.fileSize,
    required this.createdAt,
  });

  factory SkrbHistoryItem.fromJson(Map<String, dynamic> json) {
    return SkrbHistoryItem(
      id: json['id'] ?? 0,
      skrbId: int.tryParse('${json['skrb_id']}') ?? 0,
      fileName: json['file_name'] ?? '',
      storagePath: json['storage_path'] ?? '',
      fileSize: int.tryParse('${json['file_size']}') ?? 0,
      createdAt: '${json['created_at'] ?? ''}',
    );
  }
}

class SkrbAvailableTransaction {
  final String id;
  final String customerName;
  final String merk;
  final String typeChassis;
  final String jenisKendaraan;
  final String jenisPengajuan;

  SkrbAvailableTransaction({
    required this.id,
    required this.customerName,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    required this.jenisPengajuan,
  });

  factory SkrbAvailableTransaction.fromJson(Map<String, dynamic> json) {
    return SkrbAvailableTransaction(
      id: '${json['id'] ?? ''}',
      customerName: json['customer_name'] ?? '-',
      merk: json['merk'] ?? '-',
      typeChassis: json['type_chassis'] ?? '-',
      jenisKendaraan: json['jenis_kendaraan'] ?? '-',
      jenisPengajuan: json['jenis_pengajuan'] ?? 'Varian',
    );
  }

  @override
  String toString() => '$id - $customerName ($merk / $typeChassis)';
}

class Skrb {
  final int id;
  final String idSkrb;
  final String transaksiId;
  final int? customerId;
  final String customerName;
  final String typeEngine;
  final String merk;
  final String typeChassis;
  final String jenisKendaraan;
  final String jenisPengajuan;
  final String statusTdp;
  final String? tdpMasaBerlaku;
  final bool isTdpOutdated;
  final bool hasKopSurat;
  final String kopSource;
  final int fase;
  final String? fotoCopySkrb;
  final String? suggestedFileName;
  final Map<String, dynamic> customFiles;
  final Map<String, dynamic> hiddenFlags;
  final Map<String, dynamic> snapshotDocuments;
  final List<SkrbHistoryItem> histories;
  final String createdAt;
  final String updatedAt;
  final bool alreadyExists;

  Skrb({
    required this.id,
    required this.idSkrb,
    required this.transaksiId,
    this.customerId,
    required this.customerName,
    required this.typeEngine,
    required this.merk,
    required this.typeChassis,
    required this.jenisKendaraan,
    required this.jenisPengajuan,
    required this.statusTdp,
    this.tdpMasaBerlaku,
    this.isTdpOutdated = false,
    this.hasKopSurat = true,
    this.kopSource = 'customer',
    required this.fase,
    this.fotoCopySkrb,
    this.suggestedFileName,
    required this.customFiles,
    required this.hiddenFlags,
    required this.snapshotDocuments,
    required this.histories,
    required this.createdAt,
    required this.updatedAt,
    this.alreadyExists = false,
  });

  factory Skrb.fromJson(Map<String, dynamic> json) {
    var histList = <SkrbHistoryItem>[];
    if (json['histories'] != null && json['histories'] is List) {
      histList = (json['histories'] as List)
          .map((h) => SkrbHistoryItem.fromJson(h as Map<String, dynamic>))
          .toList();
    }

    return Skrb(
      id: json['id'] ?? 0,
      idSkrb: json['id_skrb'] ?? '',
      transaksiId: '${json['transaksi_id'] ?? ''}',
      customerId: int.tryParse('${json['customer_id']}'),
      customerName: json['customer_name'] ?? '-',
      typeEngine: json['type_engine'] ?? '-',
      merk: json['merk'] ?? '-',
      typeChassis: json['type_chassis'] ?? '-',
      jenisKendaraan: json['jenis_kendaraan'] ?? '-',
      jenisPengajuan: json['jenis_pengajuan'] ?? 'Varian',
      statusTdp:
          (json['is_tdp_outdated'] == true ||
              json['status_tdp'] == 'Diperbarui Admin')
          ? 'Diperbarui Admin'
          : (json['status_tdp'] ?? '-'),
      tdpMasaBerlaku: json['tdp_masa_berlaku'] != null
          ? '${json['tdp_masa_berlaku']}'
          : null,
      isTdpOutdated: json['is_tdp_outdated'] == true,
      hasKopSurat: json['has_kop_surat'] == false ? false : true,
      kopSource: json['kop_source'] ?? 'customer',
      fase: int.tryParse('${json['fase']}') ?? 1,
      fotoCopySkrb: json['foto_copy_skrb']?.toString(),
      suggestedFileName: json['suggested_file_name']?.toString(),
      customFiles: json['custom_files'] != null && json['custom_files'] is Map
          ? Map<String, dynamic>.from(json['custom_files'])
          : {},
      hiddenFlags: json['hidden_flags'] != null && json['hidden_flags'] is Map
          ? Map<String, dynamic>.from(json['hidden_flags'])
          : {},
      snapshotDocuments:
          json['snapshot_documents'] != null &&
              json['snapshot_documents'] is Map
          ? Map<String, dynamic>.from(json['snapshot_documents'])
          : {},
      histories: histList,
      createdAt: json['created_at'] ?? '-',
      updatedAt: json['updated_at'] ?? '-',
      alreadyExists: json['already_exists'] == true,
    );
  }

  bool isFileUpdatedInCurrentPhase(String key) {
    if (fase == 2) return false;
    final isSystem = ['1', '2', '3', '4', 'a', 'b', 'c', 'd'].contains(key);
    if (isSystem) return true;
    final modKeys = snapshotDocuments['modified_keys'];
    if (modKeys is Map && modKeys[key] == true) return true;
    return false;
  }
}
