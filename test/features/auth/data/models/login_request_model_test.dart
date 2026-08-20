import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/auth/data/models/login_request_model.dart';

void main() {
  test('LoginRequestModel serializes to json', () {
    const request = LoginRequestModel(username: 'admin', password: 'admin123456');

    expect(request.toJson(), {'username': 'admin', 'password': 'admin123456'});
  });
}
