import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/local_storage_providers.dart';
import 'package:ilms/features/premise/data/datasources/local/premise_draft_local_data_source.dart';
import 'package:ilms/features/premise/data/repositories/premise_draft_repository_impl.dart';
import 'package:ilms/features/premise/domain/entities/premise_draft_summary.dart';
import 'package:ilms/features/premise/domain/repositories/premise_draft_repository.dart';

final premiseDraftLocalDataSourceProvider = Provider<PremiseDraftLocalDataSource>((ref) {
  return PremiseDraftLocalDataSource(ref.watch(appDatabaseProvider));
});

final premiseDraftRepositoryProvider = Provider<PremiseDraftRepository>((ref) {
  return PremiseDraftRepositoryImpl(ref.watch(premiseDraftLocalDataSourceProvider));
});

final premiseDraftListProvider = StreamProvider<List<PremiseDraftSummary>>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchDrafts();
});

final premiseDraftCountProvider = StreamProvider<int>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchDraftCount();
});

final premiseLatestDraftProvider = StreamProvider<PremiseDraftSummary?>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchLatestDraft();
});
