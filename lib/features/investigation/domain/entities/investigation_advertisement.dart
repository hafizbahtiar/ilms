import 'package:equatable/equatable.dart';

/// Advertisement block inside Maklumat Premis.
///
/// [displayed] gates [location]; [compliant] gates [nonCompliantReason].
/// [malayLanguage]/[sizeCompliant]/[spellingCompliant] are independent
/// booleans.
class InvestigationAdvertisement extends Equatable {
  const InvestigationAdvertisement({
    this.displayed = false,
    this.location,
    this.compliant = false,
    this.nonCompliantReason,
    this.malayLanguage = false,
    this.sizeCompliant = false,
    this.spellingCompliant = false,
  });

  final bool displayed;
  final String? location;
  final bool compliant;
  final String? nonCompliantReason;
  final bool malayLanguage;
  final bool sizeCompliant;
  final bool spellingCompliant;

  InvestigationAdvertisement copyWith({
    bool? displayed,
    String? location,
    bool? compliant,
    String? nonCompliantReason,
    bool? malayLanguage,
    bool? sizeCompliant,
    bool? spellingCompliant,
  }) {
    return InvestigationAdvertisement(
      displayed: displayed ?? this.displayed,
      location: location ?? this.location,
      compliant: compliant ?? this.compliant,
      nonCompliantReason: nonCompliantReason ?? this.nonCompliantReason,
      malayLanguage: malayLanguage ?? this.malayLanguage,
      sizeCompliant: sizeCompliant ?? this.sizeCompliant,
      spellingCompliant: spellingCompliant ?? this.spellingCompliant,
    );
  }

  @override
  List<Object?> get props => [
    displayed,
    location,
    compliant,
    nonCompliantReason,
    malayLanguage,
    sizeCompliant,
    spellingCompliant,
  ];
}
