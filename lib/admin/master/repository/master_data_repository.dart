import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/app/core/providers.dart';

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
  final Ref _ref;
  MasterDataRepository(this._ref);

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
    required String id,
    required String typeEngine,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/type-engines/$id', data: {'type_engine': typeEngine});
    return TypeEngine.fromJson(response.data);
  }

  Future<void> deleteTypeEngine({required String id}) async {
    await _ref.read(apiClientProvider).dio.delete('/type-engines/$id');
  }

  Future<List<Merk>> getMerks() async {
    final response = await _ref.read(apiClientProvider).dio.get('/merks');
    final List<dynamic> data = response.data;
    return data.map((item) => Merk.fromJson(item)).toList();
  }

  Future<Merk> addMerk({
    required String typeEngineId,
    required String merk,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post('/merks', data: {'type_engine_id': typeEngineId, 'merk': merk});
    return Merk.fromJson(response.data);
  }

  Future<Merk> updateMerk({required String id, required String merk}) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/merks/$id', data: {'merk': merk});
    return Merk.fromJson(response.data);
  }

  Future<void> deleteMerk({required String id}) async {
    await _ref.read(apiClientProvider).dio.delete('/merks/$id');
  }

  // --- TAMBAHKAN FUNGSI UNTUK TYPE CHASSIS ---
  Future<List<TypeChassis>> getTypeChassis() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/type-chassis');
    final List<dynamic> data = response.data;
    return data.map((item) => TypeChassis.fromJson(item)).toList();
  }

  Future<TypeChassis> addTypeChassis({
    required String merkId,
    required String typeChassis,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/type-chassis',
          data: {'merk_id': merkId, 'type_chassis': typeChassis},
        );
    return TypeChassis.fromJson(response.data);
  }

  Future<TypeChassis> updateTypeChassis({
    required String id,
    required String typeChassis,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/type-chassis/$id', data: {'type_chassis': typeChassis});
    return TypeChassis.fromJson(response.data);
  }

  Future<void> deleteTypeChassis({required String id}) async {
    await _ref.read(apiClientProvider).dio.delete('/type-chassis/$id');
  }

  Future<List<JenisKendaraan>> getJenisKendaraanList() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/jenis-kendaraan');
    final List<dynamic> data = response.data;
    return data.map((item) => JenisKendaraan.fromJson(item)).toList();
  }

  Future<JenisKendaraan> addJenisKendaraan({
    required String typeChassisId,
    required String jenisKendaraan,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/jenis-kendaraan',
          data: {
            'type_chassis_id': typeChassisId,
            'jenis_kendaraan': jenisKendaraan,
          },
        );
    return JenisKendaraan.fromJson(response.data);
  }

  Future<JenisKendaraan> updateJenisKendaraan({
    required String id,
    required String jenisKendaraan,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put('/jenis-kendaraan/$id', data: {'jenis_kendaraan': jenisKendaraan});
    return JenisKendaraan.fromJson(response.data);
  }

  Future<void> deleteJenisKendaraan({required String id}) async {
    await _ref.read(apiClientProvider).dio.delete('/jenis-kendaraan/$id');
  }

  // --- TAMBAHKAN FUNGSI UNTUK VARIAN BODY ---
  Future<List<VarianBody>> getVarianBodyList() async {
    final response = await _ref.read(apiClientProvider).dio.get('/varian-body');
    final List<dynamic> data = response.data;
    return data.map((item) => VarianBody.fromJson(item)).toList();
  }

  Future<VarianBody> addVarianBody({
    required String jenisKendaraanId,
    required String varianBody,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .post(
          '/varian-body',
          data: {
            'jenis_kendaraan_id': jenisKendaraanId,
            'varian_body': varianBody,
          },
        );
    return VarianBody.fromJson(response.data);
  }

  Future<VarianBody> updateVarianBody({
    required int id,
    required String jenisKendaraanId,
    required String varianBody,
  }) async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .put(
          '/varian-body/$id',
          data: {
            'jenis_kendaraan_id': jenisKendaraanId,
            'varian_body': varianBody,
          },
        );
    return VarianBody.fromJson(response.data);
  }

  Future<void> deleteVarianBody({required int id}) async {
    await _ref.read(apiClientProvider).dio.delete('/varian-body/$id');
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
  Future<GGambarUtama> uploadGambarUtama({
    required int varianBodyId,
    required File gambarUtama,
    required File gambarTerurai,
    required File gambarKontruksi,
  }) async {
    final formData = FormData.fromMap({
      'e_varian_body_id': varianBodyId,
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

    // Parse dan kembalikan objek GGambarUtama
    return GGambarUtama.fromJson(response.data);
  }

  // --- TAMBAHKAN FUNGSI UNTUK GAMBAR OPTIONAL ---
  Future<List<GambarOptional>> getGambarOptionalList() async {
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/gambar-optional');
    final List<dynamic> data = response.data;
    return data.map((item) => GambarOptional.fromJson(item)).toList();
  }

  Future<void> addGambarOptional({
    required String deskripsi,
    required File gambarOptionalFile,
    String tipe = 'independen',
    int? varianBodyId, // <-- Diubah menjadi nullable
    int? gambarUtamaId,
  }) async {
    final fileName = gambarOptionalFile.path.split(Platform.pathSeparator).last;

    // 1. Mulai dengan map yang berisi data umum
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
      // tipe == 'dependen'
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

  //tambahkan fungsi untuk gambar kelistrikan berdasarkan id type chassis
  // == GAMBAR KELISTRIKAN ==
  Future<List<GambarKelistrikan>> getGambarKelistrikanList() async {
    // Pastikan endpoint ini sudah ada di api.php Anda
    final response = await _ref
        .read(apiClientProvider)
        .dio
        .get('/admin/gambar-kelistrikan');
    final List<dynamic> data = response.data;
    return data.map((item) => GambarKelistrikan.fromJson(item)).toList();
  }

  Future<void> addGambarKelistrikan({
    required String typeChassisId,
    required String deskripsi,
    required File gambarKelistrikanFile,
  }) async {
    final fileName = gambarKelistrikanFile.path
        .split(Platform.pathSeparator)
        .last;
    final formData = FormData.fromMap({
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

  Future<void> deleteGambarKelistrikan({required int id}) async {
    await _ref
        .read(apiClientProvider)
        .dio
        .delete('/admin/gambar-kelistrikan/$id');
  }
}
