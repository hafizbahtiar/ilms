import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/premise/data/datasources/api_premise_status_summary_remote_data_source.dart';
import 'package:ilms/features/premise/data/datasources/premise_status_summary_remote_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_status_summary_repository_impl.dart';
import 'package:ilms/features/premise/domain/entities/premise_status_summary.dart';
import 'package:ilms/features/premise/domain/repositories/premise_status_summary_repository.dart';

final premiseStatusSummaryRemoteDataSourceProvider = Provider<PremiseStatusSummaryRemoteDataSource>((ref) {
  return ApiPremiseStatusSummaryRemoteDataSource(ref.watch(dioClientProvider));
});

final premiseStatusSummaryRepositoryProvider = Provider<PremiseStatusSummaryRepository>((ref) {
  return PremiseStatusSummaryRepositoryImpl(ref.watch(premiseStatusSummaryRemoteDataSourceProvider));
});

/// Today's visit-status summary for the homepage donut chart.
final premiseStatusSummaryProvider = FutureProvider<PremiseStatusSummary>((ref) {
  final repository = ref.watch(premiseStatusSummaryRepositoryProvider);
  return repository.getStatusSummary();
});
