import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_search_providers.dart';
import 'package:ilms/features/billboard/presentation/providers/billboard_status_summary_providers.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_providers.dart';
import 'package:ilms/features/investigation/presentation/providers/investigation_search_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_address_listing_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_detail_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_duplicate_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_license_qr_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_search_providers.dart';
import 'package:ilms/features/premise/presentation/providers/premise_status_summary_providers.dart';
import 'package:ilms/shared/lookups/providers/general_lookup_providers.dart';

/// Drops cached network providers and lookup data after an environment switch.
Future<void> invalidateNetworkProviders(WidgetRef ref) async {
  ref.invalidate(dioClientProvider);
  ref.invalidate(generalLookupDataSourceProvider);
  ref.invalidate(premiseStatusSummaryRemoteDataSourceProvider);
  ref.invalidate(billboardStatusSummaryRemoteDataSourceProvider);
  ref.invalidate(premiseSearchRemoteDataSourceProvider);
  ref.invalidate(premiseDetailRemoteDataSourceProvider);
  ref.invalidate(premiseDuplicateRemoteDataSourceProvider);
  ref.invalidate(premiseAddressListingRemoteDataSourceProvider);
  ref.invalidate(premiseLicenseQrRemoteDataSourceProvider);
  ref.invalidate(billboardSearchRemoteDataSourceProvider);
  ref.invalidate(billboardDetailRemoteDataSourceProvider);
  ref.invalidate(investigationDataSourceProvider);
  ref.invalidate(investigationDetailRemoteDataSourceProvider);
  ref.invalidate(investigationSearchRemoteDataSourceProvider);
  ref.invalidate(premiseStatusSummaryProvider);
  ref.invalidate(billboardStatusSummaryProvider);

  await ref.read(generalLookupRepositoryProvider).clearAllCaches();
  ref.invalidate(generalStatesProvider);
  ref.invalidate(generalBusinessTypesProvider);
  ref.invalidate(generalPremiseTypesProvider);
  ref.invalidate(generalVisitBusinessTypesProvider);
  ref.invalidate(generalVisitStatusesProvider);
  ref.invalidate(generalImageTypesProvider);
  ref.invalidate(generalRemarksProvider);
  ref.invalidate(generalBusinessActivityStatusesProvider);
  ref.invalidate(generalBusinessLicenseStatusesProvider);
  ref.invalidate(generalPhasesProvider);
  ref.invalidate(billboardPhasesProvider);
  ref.invalidate(billboardTypesProvider);
  ref.invalidate(billboardAssetOwnersProvider);
  ref.invalidate(billboardRemarksProvider);
  ref.invalidate(generalYesNoProvider);
  ref.invalidate(generalPostcodesProvider);
  ref.invalidate(generalAreasProvider);
  ref.invalidate(generalParliamentsProvider);
  ref.invalidate(generalAreasByParliamentProvider);
  ref.invalidate(generalStreetsProvider);
  ref.invalidate(generalBuildingsProvider);
  ref.invalidate(generalUnitsProvider);
}
