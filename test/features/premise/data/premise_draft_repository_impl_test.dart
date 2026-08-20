import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/core/local/database/app_database.dart';
import 'package:ilms/features/premise/data/datasources/local/premise_draft_local_data_source.dart';
import 'package:ilms/features/premise/data/models/premise_draft_payload_model.dart';
import 'package:ilms/features/premise/data/repositories/premise_draft_repository_impl.dart';
import 'package:ilms/features/premise/domain/entities/premise_census_image.dart';

void main() {
  group('PremiseDraftRepositoryImpl', () {
    late AppDatabase database;
    late PremiseDraftRepositoryImpl repository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await AppDatabase.init(database: database);
      repository = PremiseDraftRepositoryImpl(PremiseDraftLocalDataSource(database));
    });

    tearDown(() {
      AppDatabase.reset();
    });

    test('saveDraft creates and updates local draft', () async {
      final payload = PremiseDraftPayloadModel(
        companyStateCode: '14',
        fields: const {'companyName': 'Acme Sdn Bhd', 'traderName': 'Acme Trader'},
      );

      final id = await repository.saveDraft(
        payload: payload,
        companyName: 'Acme Sdn Bhd',
        traderName: 'Acme Trader',
      );

      final loaded = await repository.loadDraft(id);
      expect(loaded?.payload.fields['companyName'], 'Acme Sdn Bhd');
      expect(loaded?.payload.companyStateCode, '14');

      await repository.saveDraft(
        localDraftId: id,
        payload: PremiseDraftPayloadModel(
          companyStateCode: '14',
          fields: const {'companyName': 'Updated Co', 'traderName': 'Updated Trader'},
        ),
        companyName: 'Updated Co',
        traderName: 'Updated Trader',
      );

      final updated = await repository.loadDraft(id);
      expect(updated?.payload.fields['companyName'], 'Updated Co');
    });

    test('watchDraftCount excludes synced drafts', () async {
      final id = await repository.saveDraft(
        payload: const PremiseDraftPayloadModel(fields: {'companyName': 'Draft A'}),
        companyName: 'Draft A',
        traderName: '',
      );

      expect(await repository.watchDraftCount().first, 1);

      await repository.markDraftSynced(id);
      expect(await repository.watchDraftCount().first, 0);
    });

    test('saveDraft persists census images', () async {
      const payload = PremiseDraftPayloadModel(
        fields: {'companyName': 'Photo Co'},
        censusImages: [
          PremiseCensusImage(localPath: '/tmp/census_1.jpg', typeDescription: 'Front'),
        ],
      );

      final id = await repository.saveDraft(
        payload: payload,
        companyName: 'Photo Co',
        traderName: '',
      );

      final loaded = await repository.loadDraft(id);
      expect(loaded?.payload.censusImages, hasLength(1));
      expect(loaded?.payload.censusImages.first.localPath, '/tmp/census_1.jpg');
    });

    test('duplicateDraft creates a new draft with the same payload', () async {
      const payload = PremiseDraftPayloadModel(
        fields: {'companyName': 'Original Co', 'traderName': 'Trader A'},
        censusImages: [
          PremiseCensusImage(localPath: '/tmp/census_1.jpg'),
        ],
      );

      final sourceId = await repository.saveDraft(
        payload: payload,
        companyName: 'Original Co',
        traderName: 'Trader A',
      );

      final copyId = await repository.duplicateDraft(sourceId);
      expect(copyId, isNot(sourceId));

      final copy = await repository.loadDraft(copyId);
      expect(copy?.payload.fields['companyName'], 'Original Co');
      expect(copy?.payload.censusImages, hasLength(1));

      expect(await repository.watchDraftCount().first, 2);
    });

    test('deleteDraft removes draft from list', () async {
      final id = await repository.saveDraft(
        payload: const PremiseDraftPayloadModel(fields: {'companyName': 'To delete'}),
        companyName: 'To delete',
        traderName: '',
      );

      expect(await repository.getLatestDraft(), isNotNull);

      await repository.deleteDraft(id);

      expect(await repository.getLatestDraft(), isNull);
    });
  });
}
