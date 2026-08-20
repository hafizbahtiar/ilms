import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/data/models/login_response_model.dart';

void main() {
  test('LoginResponseModel parses success payload', () {
    final model = LoginResponseModel.fromJson({
      'status': 'success',
      'message': 'Login successfully!',
      'data': {
        'access_token': '1903|token',
        'token_type': 'Bearer',
        'expires_at': '2026-08-20 03:45:45',
        'name': 'Administrator',
        'email': 'admin@admin.com',
        'roles': ['admin'],
        'permissions': ['view-mobile-premise', 'view-mobile-billboard', 'view-mobile-investigation'],
      },
    });

    expect(model.status, 'success');
    expect(model.message, 'Login successfully!');
    expect(model.data?.accessToken, '1903|token');
    expect(model.data?.tokenType, 'Bearer');
    expect(model.data?.name, 'Administrator');
    expect(model.data?.email, 'admin@admin.com');
    expect(model.data?.roles, ['admin']);
    expect(model.data?.permissions.length, 3);
    expect(model.data?.expiresAt, DateTime.parse('2026-08-20T03:45:45'));
  });
}
