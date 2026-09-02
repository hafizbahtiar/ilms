import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_address_listing_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_address_listing_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_address_listing_repository_impl.dart';
import 'package:ilms/features/premise/domain/repositories/premise_address_listing_repository.dart';

final premiseAddressListingRemoteDataSourceProvider = Provider<PremiseAddressListingRemoteDataSource>((ref) {
  return ApiPremiseAddressListingRemoteDataSource(ref.watch(dioClientProvider));
});

final premiseAddressListingRepositoryProvider = Provider<PremiseAddressListingRepository>((ref) {
  return PremiseAddressListingRepositoryImpl(ref.watch(premiseAddressListingRemoteDataSourceProvider));
});
