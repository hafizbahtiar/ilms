import 'package:ilms/features/premise/data/datasources/premise_detail_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_detail_record.dart';
import 'package:ilms/features/premise/domain/repositories/premise_detail_repository.dart';

class PremiseDetailRepositoryImpl implements PremiseDetailRepository {
  PremiseDetailRepositoryImpl(this._remote);

  final PremiseDetailRemoteDataSource _remote;

  @override
  Future<PremiseDraftPayloadModel> getDetail(String visitNo) => _remote.getDetail(visitNo);

  @override
  Future<PremiseDetailRecord> getDetailRecord(String visitNo) => _remote.getDetailRecord(visitNo);
}
