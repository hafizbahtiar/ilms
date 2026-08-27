import 'package:ilms/features/premise/data/datasources/premise_address_listing_remote_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_address_listing_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_filter.dart';
import 'package:ilms/features/premise/domain/repositories/premise_address_listing_repository.dart';

class PremiseAddressListingRepositoryImpl implements PremiseAddressListingRepository {
  PremiseAddressListingRepositoryImpl(this._remote);

  final PremiseAddressListingRemoteDataSource _remote;

  @override
  Future<PremiseAddressListingPageModel> search(PremiseAddressFilter filter) {
    return _remote.search(filter);
  }
}
