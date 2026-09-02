import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/network/dio_client_provider.dart';
import 'package:ilms/features/billboard/data/datasources/api_billboard_status_summary_remote_data_source.dart';
import 'package:ilms/features/billboard/data/datasources/billboard_status_summary_remote_data_source.dart';
import 'package:ilms/features/billboard/data/repositories/billboard_status_summary_repository_impl.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_status_summary.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_status_summary_repository.dart';

final billboardStatusSummaryRemoteDataSourceProvider = Provider<BillboardStatusSummaryRemoteDataSource>((ref) {
  return ApiBillboardStatusSummaryRemoteDataSource(ref.watch(dioClientProvider));
});

final billboardStatusSummaryRepositoryProvider = Provider<BillboardStatusSummaryRepository>((ref) {
  return BillboardStatusSummaryRepositoryImpl(ref.watch(billboardStatusSummaryRemoteDataSourceProvider));
});

/// Today's billboard-type summary for the homepage/list activity chart.
final billboardStatusSummaryProvider = FutureProvider<BillboardStatusSummary>((ref) {
  final repository = ref.watch(billboardStatusSummaryRepositoryProvider);
  return repository.getStatusSummary();
});
