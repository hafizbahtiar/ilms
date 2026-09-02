import 'package:flutter_test/flutter_test.dart';
import 'package:ilms/features/premise/data/models/premise_submit_payload_model.dart';
import 'package:ilms/features/premise/domain/entities/premise_address.dart';
import 'package:ilms/features/premise/domain/utils/premise_coordinate.dart';
import 'package:ilms/features/premise/presentation/utils/premise_address_location.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('parsePremiseCoordinate treats zero as empty', () {
    expect(parsePremiseCoordinate('0.000000'), isNull);
    expect(parsePremiseCoordinate('0'), isNull);
    expect(parsePremiseCoordinate('3.139012'), 3.139012);
  });

  test('latLngFromPremiseAddress ignores zero coordinates', () {
    const address = PremiseAddress(latitude: '0.000000', longitude: '0.000000');
    expect(latLngFromPremiseAddress(address), isNull);
    expect(premiseAddressHasLocation(address), isFalse);
  });

  test('premiseAddressWithCoordinates stores latitude and longitude as strings', () {
    const address = PremiseAddress(unitNo: '12A');
    const coordinates = LatLng(3.139012, 101.686901);

    final updated = premiseAddressWithCoordinates(address, coordinates);

    expect(updated.latitude, '3.139012');
    expect(updated.longitude, '101.686901');
  });

  test('PremiseAddressRequest sends coordinates to backend payload', () {
    const address = PremiseAddress(unitNo: '12A', latitude: '3.139012', longitude: '101.686901');

    final json = PremiseAddressRequest.fromDomain(address).toJson();

    expect(json['latitude'], '3.139012');
    expect(json['longitude'], '101.686901');
  });
}
