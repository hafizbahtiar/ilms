import 'package:ilms/features/premise/data/models/premise_address_listing_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address_filter.dart';

abstract class PremiseAddressListingRemoteDataSource {
  Future<PremiseAddressListingPageModel> search(PremiseAddressFilter filter);
}
