import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/profile/data/models/profile_response_model.dart';

void main() {
  test('ProfileResponseModel parses success payload', () {
    final model = ProfileResponseModel.fromJson({
      'status': 'success',
      'message': 'Profile loaded',
      'data': {
        'name': 'Administrator',
        'email': 'admin@admin.com',
        'phone': '0123456789',
      },
    });

    expect(model.status, 'success');
    expect(model.message, 'Profile loaded');
    expect(model.data?.name, 'Administrator');
    expect(model.data?.email, 'admin@admin.com');
    expect(model.data?.phone, '0123456789');
  });
}
