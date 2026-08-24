import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/local_storage_providers.dart';
import 'package:ilms/features/investigation/data/datasources/local/investigation_draft_local_data_source.dart';
import 'package:ilms/features/investigation/data/repositories/investigation_draft_repository_impl.dart';
import 'package:ilms/features/investigation/domain/entities/investigation_draft_summary.dart';
import 'package:ilms/features/investigation/domain/repositories/investigation_draft_repository.dart';

final investigationDraftLocalDataSourceProvider = Provider<InvestigationDraftLocalDataSource>((ref) {
  return InvestigationDraftLocalDataSource(ref.watch(appDatabaseProvider));
});

final investigationDraftRepositoryProvider = Provider<InvestigationDraftRepository>((ref) {
  return InvestigationDraftRepositoryImpl(ref.watch(investigationDraftLocalDataSourceProvider));
});

final investigationDraftListProvider = StreamProvider<List<InvestigationDraftSummary>>((ref) {
  return ref.watch(investigationDraftRepositoryProvider).watchDrafts();
});

final investigationHasDraftProvider = StreamProvider.family<bool, String>((ref, investigationNo) {
  return ref.watch(investigationDraftRepositoryProvider).watchHasDraft(investigationNo);
});
