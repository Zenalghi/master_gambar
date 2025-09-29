import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_gambar/admin/master/models/type_engine.dart';
import 'package:master_gambar/app/core/providers.dart';

import '../models/merk.dart';

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
}
