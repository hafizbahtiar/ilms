import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ilms/core/local/local_storage_providers.dart';
import 'package:ilms/features/billboard/data/datasources/local/billboard_draft_local_data_source.dart';
import 'package:ilms/features/billboard/data/repositories/billboard_draft_repository_impl.dart';
import 'package:ilms/features/billboard/domain/entities/billboard_draft_summary.dart';
import 'package:ilms/features/billboard/domain/repositories/billboard_draft_repository.dart';

final billboardDraftLocalDataSourceProvider = Provider<BillboardDraftLocalDataSource>((ref) {
  return BillboardDraftLocalDataSource(ref.watch(appDatabaseProvider));
});

final billboardDraftRepositoryProvider = Provider<BillboardDraftRepository>((ref) {
  return BillboardDraftRepositoryImpl(ref.watch(billboardDraftLocalDataSourceProvider));
});

final billboardDraftListProvider = StreamProvider<List<BillboardDraftSummary>>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchDrafts();
});

final billboardDraftCountProvider = StreamProvider<int>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchDraftCount();
});

final billboardLatestDraftProvider = StreamProvider<BillboardDraftSummary?>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchLatestDraft();
});

/// billboardNo of every billboard record with a pending local unsaved edit —
/// used to show an "Unsaved" tag on list tiles.
final billboardEditSessionBillboardNosProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchEditSessionBillboardNos();
});

final billboardEditSessionCountProvider = StreamProvider<int>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchEditSessions().map((items) => items.length);
});

/// New-entry drafts and pending local unsaved edits together, for the
/// Drafts page.
final billboardDraftsAndEditSessionsProvider = StreamProvider<List<BillboardDraftSummary>>((ref) {
  return ref.watch(billboardDraftRepositoryProvider).watchDraftsAndEditSessions();
});
