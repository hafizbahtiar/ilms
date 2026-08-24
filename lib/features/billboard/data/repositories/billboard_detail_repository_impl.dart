import 'package:ilms/features/billboard/data/datasources/billboard_detail_remote_data_source.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_form.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_detail_repository.dart';

class BillboardDetailRepositoryImpl implements BillboardDetailRepository {
  BillboardDetailRepositoryImpl(this._remote);

  final BillboardDetailRemoteDataSource _remote;

  @override
  Future<BillboardForm> getDetail(String billboardNo) => _remote.getDetail(billboardNo);
}
