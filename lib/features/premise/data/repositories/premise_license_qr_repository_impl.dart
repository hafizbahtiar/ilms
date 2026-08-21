import 'package:ilms/features/premise/data/datasources/premise_license_qr_remote_data_source.dart';
import 'package:ilms/features/premise/data/mappers/premise_license_qr_mapper.dart';
import 'package:ilms/features/premise/domain/entities/premise_license_qr_data.dart';
import 'package:ilms/features/premise/domain/repositories/premise_license_qr_repository.dart';

class PremiseLicenseQrRepositoryImpl implements PremiseLicenseQrRepository {
  PremiseLicenseQrRepositoryImpl(this._remote);

  final PremiseLicenseQrRemoteDataSource _remote;

  @override
  Future<PremiseLicenseQrData> fetchByLink(String link) async {
    final model = await _remote.getByLink(link);
    return PremiseLicenseQrMapper.toDomain(model);
  }
}
