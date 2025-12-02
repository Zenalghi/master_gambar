//lib\admin\master\repository\master_data_repository.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';
import '../../../data/models/option_item.dart';
import '../../../data/models/paginated_response.dart';
import '../models/image_status.dart';
import '../models/master_data.dart';
import '../models/type_engine.dart';
import '../models/merk.dart';
import '../models/type_chassis.dart';
import '../models/jenis_kendaraan.dart';
import '../models/varian_body.dart';
import '../models/jenis_varian.dart';
import '../models/gambar_optional.dart';
import '../models/gambar_kelistrikan.dart';
import '../models/g_gambar_utama.dart';

final masterDataRepositoryProvider = Provider(
  (ref) => MasterDataRepository(ref),
);

class MasterDataRepository {
  final Ref _ref; // Ini adalah _ref yang digunakan di seluruh class
  MasterDataRepository(this._ref);

  // --- METODE BARU YANG ANDA BUTUHKAN ---
  // Method ini harus berada DI DALAM kurung kurawal class MasterDataRepository
  Future<List<OptionItem>> getMasterDataOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/master-data', queryParameters: {'search': search});

    // Backend mengirim list, kita mapping ke OptionItem
    final List<dynamic> data = response.data;
    return data.map((e) => OptionItem.fromJson(e, nameKey: 'name')).toList();
  }

  // == TYPE ENGINE ==
  Future<List<TypeEngine>> getTypeEngines() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/type-engines');
    final List<dynamic> data = response.data;
    return data.map((item) => TypeEngine.fromJson(item)).toList();
  }

  Future<TypeEngine> addTypeEngine({required String typeEngine}) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/type-engines', data: {'type_engine': typeEngine});
    return TypeEngine.fromJson(response.data);
  }

  Future<TypeEngine> updateTypeEngine({
    required int id,
    required String typeEngine,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/type-engines/$id', data: {'type_engine': typeEngine});
    return TypeEngine.fromJson(response.data);
  }

  Future<void> deleteTypeEngine({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/type-engines/$id');
  }

  // --- FITUR RECYCLE BIN TYPE ENGINE ---
  Future<List<TypeEngine>> getDeletedTypeEngines() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/type-engines/trash');
    // Karena trash mengembalikan list objek juga, kita parsing manual
    final List<dynamic> data = response.data;
    // Perlu sedikit trik karena model TypeEngine mungkin tidak menghandle deletedAt di fromJson standar
    // Tapi untuk list sederhana ID & Nama, fromJson biasa sudah cukup.
    return data.map((item) => TypeEngine.fromJson(item)).toList();
  }

  Future<void> restoreTypeEngine(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/type-engines/$id/restore');
  }

  Future<void> forceDeleteTypeEngine(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/type-engines/$id/force-delete');
  }

  // == MERK (PAGINATED) ==
  Future<PaginatedResponse<Merk>> getMerksPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'id',
    String sortDirection = 'asc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/merks',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, Merk.fromJson);
  }

  Future<List<Merk>> getMerks() async {
    // Method lama untuk dropdown biasa (jika masih dipakai)
    final response = await _ref.read(apiClientProvider).dio.get('/merks');
    final List<dynamic> data = response.data;
    return data.map((item) => Merk.fromJson(item)).toList();
  }

  Future<Merk> addMerk({
    // typeEngineId dihapus karena independen
    required String merk,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/merks', data: {'merk': merk});
    return Merk.fromJson(response.data);
  }

  Future<Merk> updateMerk({required int id, required String merk}) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/merks/$id', data: {'merk': merk});
    return Merk.fromJson(response.data);
  }

  Future<void> deleteMerk({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/merks/$id');
  }

  Future<List<Merk>> getDeletedMerks() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/merks/trash');
    final List<dynamic> data = response.data;
    return data.map((item) => Merk.fromJson(item)).toList();
  }

  Future<void> restoreMerk(int id) async {
    await _ref.read(apiClientProvider).dio.post('/admin/merks/$id/restore');
  }

  Future<void> forceDeleteMerk(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/merks/$id/force-delete');
  }

  // == TYPE CHASSIS (PAGINATED) ==
  Future<PaginatedResponse<TypeChassis>> getTypeChassisPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'id',
    String sortDirection = 'asc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/type-chassis',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, TypeChassis.fromJson);
  }

  Future<List<TypeChassis>> getTypeChassis() async {
    // Method lama (jika masih dipakai)
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/type-chassis');
    final List<dynamic> data = response.data;
    return data.map((item) => TypeChassis.fromJson(item)).toList();
  }

  Future<TypeChassis> addTypeChassis({
    // merkId dihapus karena independen
    required String typeChassis,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/type-chassis', data: {'type_chassis': typeChassis});
    return TypeChassis.fromJson(response.data);
  }

  Future<TypeChassis> updateTypeChassis({
    required int id,
    required String typeChassis,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/type-chassis/$id', data: {'type_chassis': typeChassis});
    return TypeChassis.fromJson(response.data);
  }

  Future<void> deleteTypeChassis({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/type-chassis/$id');
  }

  // == TYPE CHASSIS RECYCLE BIN ==
  Future<List<TypeChassis>> getDeletedTypeChassis() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/type-chassis/trash');
    final List<dynamic> data = response.data;
    return data.map((item) => TypeChassis.fromJson(item)).toList();
  }

  Future<void> restoreTypeChassis(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/type-chassis/$id/restore');
  }

  Future<void> forceDeleteTypeChassis(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/type-chassis/$id/force-delete');
  }

  // == JENIS KENDARAAN (PAGINATED) ==
  Future<PaginatedResponse<JenisKendaraan>> getJenisKendaraanListPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'id',
    String sortDirection = 'asc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/jenis-kendaraan',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, JenisKendaraan.fromJson);
  }

  Future<List<JenisKendaraan>> getJenisKendaraanList() async {
    // Method lama
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/jenis-kendaraan');
    final List<dynamic> data = response.data;
    return data.map((item) => JenisKendaraan.fromJson(item)).toList();
  }

  Future<JenisKendaraan> addJenisKendaraan({
    // typeChassisId dihapus karena independen
    required String jenisKendaraan,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/jenis-kendaraan', data: {'jenis_kendaraan': jenisKendaraan});
    return JenisKendaraan.fromJson(response.data);
  }

  Future<JenisKendaraan> updateJenisKendaraan({
    required int id,
    required String jenisKendaraan,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/jenis-kendaraan/$id', data: {'jenis_kendaraan': jenisKendaraan});
    return JenisKendaraan.fromJson(response.data);
  }

  Future<void> deleteJenisKendaraan({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/jenis-kendaraan/$id');
  }

  // == JENIS KENDARAAN RECYCLE BIN ==
  Future<List<JenisKendaraan>> getDeletedJenisKendaraan() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/jenis-kendaraan/trash');
    final List<dynamic> data = response.data;
    return data.map((item) => JenisKendaraan.fromJson(item)).toList();
  }

  Future<void> restoreJenisKendaraan(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/jenis-kendaraan/$id/restore');
  }

  Future<void> forceDeleteJenisKendaraan(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/jenis-kendaraan/$id/force-delete');
  }

  // == VARIAN BODY (PAGINATED) ==
  Future<PaginatedResponse<VarianBody>> getVarianBodyListPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'updated_at',
    String sortDirection = 'desc',
    String search = '',
    int? masterDataId, // <-- TAMBAHKAN PARAMETER INI
  }) async {
    // Siapkan query parameters dasar
    final queryParams = {
      'page': page,
      'perPage': perPage,
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      'search': search,
    };

    // Jika ada filter master_data_id, tambahkan ke query
    if (masterDataId != null) {
      queryParams['master_data_id'] = masterDataId;
    }

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/varian-body', queryParameters: queryParams);
    return PaginatedResponse.fromJson(response.data, VarianBody.fromJson);
  }

  Future<List<VarianBody>> getVarianBodyList() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/varian-body',
        ); // Endpoint index biasa (jika controller support all)
    // Jika controller sudah diubah ke paginate, method ini akan error karena struktur JSON beda.
    // Sebaiknya hapus atau sesuaikan jika controller hanya return paginate.
    // Untuk keamanan, saya komen dulu.
    final List<dynamic> data = response.data; //ku unkomen
    return data.map((item) => VarianBody.fromJson(item)).toList();
    // return [];
  }

  Future<VarianBody> addVarianBody({
    required int masterDataId, // <-- Pakai masterDataId
    required String varianBody,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/varian-body', // Endpoint resource
          data: {'master_data_id': masterDataId, 'varian_body': varianBody},
        );
    return VarianBody.fromJson(response.data);
  }

  Future<VarianBody> updateVarianBody({
    required int id,
    required int masterDataId,
    required String varianBody,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '/varian-body/$id',
          data: {'master_data_id': masterDataId, 'varian_body': varianBody},
        );
    return VarianBody.fromJson(response.data);
  }

  Future<void> deleteVarianBody({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/varian-body/$id');
  }

  // == VARIAN BODY RECYCLE BIN ==
  Future<List<VarianBody>> getDeletedVarianBodies() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/varian-body/trash');
    final List<dynamic> data = response.data;
    return data.map((item) => VarianBody.fromJson(item)).toList();
  }

  Future<void> restoreVarianBody(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/varian-body/$id/restore');
  }

  Future<void> forceDeleteVarianBody(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/varian-body/$id/force-delete');
  }

  // == JENIS VARIAN ==
  Future<List<JenisVarian>> getJenisVarianList() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/jenis-varian');
    final List<dynamic> data = response.data;
    return data.map((item) => JenisVarian.fromJson(item)).toList();
  }

  Future<JenisVarian> addJenisVarian({required String namaJudul}) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/jenis-varian', data: {'nama_judul': namaJudul});
    return JenisVarian.fromJson(response.data);
  }

  Future<JenisVarian> updateJenisVarian({
    required int id,
    required String namaJudul,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/admin/jenis-varian/$id', data: {'nama_judul': namaJudul});
    return JenisVarian.fromJson(response.data);
  }

  Future<void> deleteJenisVarian({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/jenis-varian/$id');
  }

  // == MASTER GAMBAR UTAMA ==
  Future<void> uploadGambarUtama({
    required int
    masterDataId, // <-- Ubah dari varianBodyId (sesuai controller baru)
    required String varianBodyName, // <-- Nama varian body
    required File gambarUtama,
    required File gambarTerurai,
    required File gambarKontruksi,
  }) async {
    final formData = FormData.fromMap({
      'master_data_id': masterDataId,
      'varian_body': varianBodyName,
      'gambar_utama': await MultipartFile.fromFile(
        gambarUtama.path,
        filename: gambarUtama.path.split(Platform.pathSeparator).last,
      ),
      'gambar_terurai': await MultipartFile.fromFile(
        gambarTerurai.path,
        filename: gambarTerurai.path.split(Platform.pathSeparator).last,
      ),
      'gambar_kontruksi': await MultipartFile.fromFile(
        gambarKontruksi.path,
        filename: gambarKontruksi.path.split(Platform.pathSeparator).last,
      ),
    });

    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/gambar-master/utama', data: formData);
  }

  // Untuk Gambar Utama, kita butuh return objeknya untuk dapat ID-nya (dipakai di UI)
  // Jadi sebaiknya uploadGambarUtama di atas return GGambarUtama, bukan void.
  // Mari kita perbaiki sekalian:
  Future<GGambarUtama> uploadGambarUtamaWithResult({
    required int masterDataId,
    required String varianBodyName,
    required File gambarUtama,
    required File gambarTerurai,
    required File gambarKontruksi,
  }) async {
    final formData = FormData.fromMap({
      'master_data_id': masterDataId,
      'varian_body': varianBodyName,
      'gambar_utama': await MultipartFile.fromFile(
        gambarUtama.path,
        filename: gambarUtama.path.split(Platform.pathSeparator).last,
      ),
      'gambar_terurai': await MultipartFile.fromFile(
        gambarTerurai.path,
        filename: gambarTerurai.path.split(Platform.pathSeparator).last,
      ),
      'gambar_kontruksi': await MultipartFile.fromFile(
        gambarKontruksi.path,
        filename: gambarKontruksi.path.split(Platform.pathSeparator).last,
      ),
    });

    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/gambar-master/utama', data: formData);

    return GGambarUtama.fromJson(response.data);
  }

  // == GAMBAR OPTIONAL ==
  Future<PaginatedResponse<GambarOptional>> getGambarOptionalListPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'updated_at',
    String sortDirection = 'desc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/gambar-optional',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, GambarOptional.fromJson);
  }

  // Method lama (hapus jika tidak dipakai)
  Future<List<GambarOptional>> getGambarOptionalList() async {
    // ... (sama seperti varian body, kemungkinan error jika controller pagination)
    return [];
  }

  Future<void> addGambarOptional({
    // Parameter disesuaikan dengan controller H_GambarOptionalController
    String tipe = 'independen',
    String deskripsi = '',
    required File gambarOptionalFile,
    int? varianBodyId, // e_varian_body_id (untuk independen)
    int? gambarUtamaId, // g_gambar_utama_id (untuk paket)
  }) async {
    final fileName = gambarOptionalFile.path.split(Platform.pathSeparator).last;

    // Bangun map data
    final Map<String, dynamic> dataMap = {
      'tipe': tipe,
      'deskripsi': deskripsi,
      'gambar_optional': await MultipartFile.fromFile(
        gambarOptionalFile.path,
        filename: fileName,
      ),
    };

    // 2. Tambahkan ID yang relevan secara kondisional
    if (tipe == 'independen') {
      dataMap['e_varian_body_id'] = varianBodyId;
    } else {
      // tipe == 'paket'
      dataMap['g_gambar_utama_id'] = gambarUtamaId;
    }

    // 3. Buat FormData dari map yang sudah benar
    final formData = FormData.fromMap(dataMap);

    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/gambar-optional', data: formData);
  }

  Future<GambarOptional> updateGambarOptional({
    required int id,
    required String deskripsi,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/admin/gambar-optional/$id', data: {'deskripsi': deskripsi});
    return GambarOptional.fromJson(response.data);
  }

  Future<void> deleteGambarOptional({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/gambar-optional/$id');
  }

  Future<Uint8List> getGambarOptionalPdf(int id) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/gambar-optional/$id/pdf',
          options: Options(responseType: ResponseType.bytes),
        );
    return response.data;
  }

  Future<bool> checkPaketOptionalExists(int varianBodyId) async {
    try {
      final response = await _ref
          .read(apiClientProvider)
          .dio
          .get('/options/check-paket-optional/$varianBodyId');
      return response.data['exists'] as bool;
    } catch (e) {
      return false;
    }
  }

  //tambahkan fungsi untuk gambar kelistrikan berdasarkan id type chassis
  // == GAMBAR KELISTRIKAN ==
  Future<PaginatedResponse<GambarKelistrikan>>
  getGambarKelistrikanListPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'updated_at',
    String sortDirection = 'desc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/gambar-kelistrikan',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(
      response.data,
      GambarKelistrikan.fromJson,
    );
  }

  Future<void> addGambarKelistrikan({
    required String typeEngineId,
    required String merkId,
    required String typeChassisId,
    required String deskripsi,
    required File gambarKelistrikanFile,
  }) async {
    final fileName = gambarKelistrikanFile.path
        .split(Platform.pathSeparator)
        .last;

    final formData = FormData.fromMap({
      'a_type_engine_id': typeEngineId,
      'b_merk_id': merkId,
      'c_type_chassis_id': typeChassisId,
      'deskripsi': deskripsi,
      'gambar_kelistrikan': await MultipartFile.fromFile(
        gambarKelistrikanFile.path,
        filename: fileName,
      ),
    });

    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/gambar-kelistrikan', data: formData);
  }

  Future<Uint8List> getGambarKelistrikanPdf(int id) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/gambar-kelistrikan/$id/pdf',
          options: Options(responseType: ResponseType.bytes),
        );
    return response.data;
  }

  Future<void> deleteGambarKelistrikan({required int id}) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/gambar-kelistrikan/$id');
  }

  Future<GambarKelistrikan> updateGambarKelistrikan({
    required int id,
    required String deskripsi,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/admin/gambar-kelistrikan/$id', data: {'deskripsi': deskripsi});
    return GambarKelistrikan.fromJson(response.data);
  }

  // == IMAGE STATUS (LAPORAN) ==
  Future<PaginatedResponse<ImageStatus>> getImageStatus({
    int page = 1,
    int perPage = 25,
    String sortBy = 'updated_at',
    String sortDirection = 'desc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/image-status',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, ImageStatus.fromJson);
  }

  // == GAMBAR UTAMA PREVIEW (PATHS & VIEW) ==
  Future<Map<String, String>> getGambarUtamaPaths(int gambarUtamaId) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/gambar-utama/$gambarUtamaId/paths');
    return Map<String, String>.from(response.data);
  }

  // 2. Method untuk mengunduh konten PDF berdasarkan path-nya
  Future<Uint8List> getPdfFromPath(String path) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/master-gambar/view',
          queryParameters: {'path': path},
          options: Options(responseType: ResponseType.bytes),
        );
    return response.data;
  }

  Future<void> deleteGambarUtama(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/gambar-master/utama/$id');
  }

  // == MASTER DATA (TABEL UTAMA) ==
  Future<PaginatedResponse<MasterData>> getMasterDataPaginated({
    int page = 1,
    int perPage = 25,
    String sortBy = 'id',
    String sortDirection = 'asc',
    String search = '',
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get(
          '/admin/master-data',
          queryParameters: {
            'page': page,
            'perPage': perPage,
            'sortBy': sortBy,
            'sortDirection': sortDirection,
            'search': search,
          },
        );
    return PaginatedResponse.fromJson(response.data, MasterData.fromJson);
  }

  Future<MasterData> addMasterData({
    required int typeEngineId, // <-- GANTI KE INT
    required int merkId, // <-- GANTI KE INT
    required int typeChassisId, // <-- GANTI KE INT
    required int jenisKendaraanId, // <-- GANTI KE INT
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/admin/master-data',
          data: {
            'a_type_engine_id': typeEngineId,
            'b_merk_id': merkId,
            'c_type_chassis_id': typeChassisId,
            'd_jenis_kendaraan_id': jenisKendaraanId,
          },
        );
    return MasterData.fromJson(response.data);
  }

  Future<MasterData> updateMasterData({
    required int id,
    required int typeEngineId, // <-- GANTI KE INT
    required int merkId, // <-- GANTI KE INT
    required int typeChassisId, // <-- GANTI KE INT
    required int jenisKendaraanId, // <-- GANTI KE INT
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '/admin/master-data/$id',
          data: {
            'a_type_engine_id': typeEngineId,
            'b_merk_id': merkId,
            'c_type_chassis_id': typeChassisId,
            'd_jenis_kendaraan_id': jenisKendaraanId,
          },
        );
    return MasterData.fromJson(response.data);
  }

  // --- RECYCLE BIN MASTER DATA ---
  Future<List<MasterData>> getDeletedMasterData() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/master-data/trash');
    return (response.data as List)
        .map((item) => MasterData.fromJson(item))
        .toList();
  }

  Future<void> restoreMasterData(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .post('/admin/master-data/$id/restore');
  }

  Future<void> forceDeleteMasterData(int id) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/master-data/$id/force-delete');
  }

  Future<void> deleteMasterData({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/admin/master-data/$id');
  }

  // == DROPDOWN OPTIONS INDEPENDEN (SEARCHABLE) ==
  Future<List<OptionItem>> getTypeEngineOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/type-engines', queryParameters: {'search': search});
    return (response.data as List)
        .map((e) => OptionItem.fromJson(e, nameKey: 'name'))
        .toList();
  }

  Future<List<OptionItem>> getMerkOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/merks', queryParameters: {'search': search});
    return (response.data as List)
        .map((e) => OptionItem.fromJson(e, nameKey: 'name'))
        .toList();
  }

  Future<List<OptionItem>> getTypeChassisOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/type-chassis', queryParameters: {'search': search});
    return (response.data as List)
        .map((e) => OptionItem.fromJson(e, nameKey: 'name'))
        .toList();
  }

  Future<List<OptionItem>> getJenisKendaraanOptions(String search) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/options/jenis-kendaraan', queryParameters: {'search': search});
    return (response.data as List)
        .map((e) => OptionItem.fromJson(e, nameKey: 'name'))
        .toList();
  }
}
