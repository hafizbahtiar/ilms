import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/billboard/data/mappers/billboard_form_mapper.dart';

void main() {
  group('BillboardFormMapper', () {
    test('maps hording_* API dates onto hoarding domain fields', () {
      final form = BillboardFormMapper.fromApiDetail({
        'billboard_no': 'BB20260001',
        'billboard_details': {'hording_start_date': '2026-01-01', 'hording_complete_date': '2026-01-15'},
        'images': [
          {'id': 7, 'url': 'https://example.com/file/abc'},
        ],
      });

      expect(form.details.hoardingStartDate, '2026-01-01');
      expect(form.details.hoardingCompleteDate, '2026-01-15');
      expect(form.photos, hasLength(1));
      expect(form.photos.first.id, 7);
      expect(form.photos.first.networkUrl, 'https://example.com/file/abc');
    });
  });
}
