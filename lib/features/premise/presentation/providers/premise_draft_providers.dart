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

/// visitNo of every premise record with a pending local unsaved edit — used
/// to show an "Unsaved" tag on list tiles.
final premiseEditSessionVisitNosProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchEditSessionVisitNos();
});

/// Every pending local unsaved edit — used for the unsaved-edits badge/list.
final premiseEditSessionListProvider = StreamProvider<List<PremiseDraftSummary>>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchEditSessions();
});

final premiseEditSessionCountProvider = StreamProvider<int>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchEditSessions().map((items) => items.length);
});

/// New-entry drafts and pending local unsaved edits together, for the
/// Drafts page.
final premiseDraftsAndEditSessionsProvider = StreamProvider<List<PremiseDraftSummary>>((ref) {
  return ref.watch(premiseDraftRepositoryProvider).watchDraftsAndEditSessions();
});
