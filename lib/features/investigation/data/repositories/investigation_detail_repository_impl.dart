import 'package:ilms/features/investigation/data/datasources/investigation_detail_remote_data_source.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_details.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_detail_repository.dart';

class InvestigationDetailRepositoryImpl implements InvestigationDetailRepository {
  InvestigationDetailRepositoryImpl(this._remote);

  final InvestigationDetailRemoteDataSource _remote;

  @override
  Future<InvestigationDetails> getDetail(String investigationNo) => _remote.getDetail(investigationNo);
}
