import 'package:equatable/equatable.dart';

/// Entertainment / food-service specific fields inside Maklumat Premis.
class InvestigationBusinessActivity extends Equatable {
  const InvestigationBusinessActivity({this.floorLength, this.floorWidth, this.openingTime, this.closingTime});

  final String? floorLength;
  final String? floorWidth;
  final String? openingTime;
  final String? closingTime;

  InvestigationBusinessActivity copyWith({
    String? floorLength,
    String? floorWidth,
    String? openingTime,
    String? closingTime,
  }) {
    return InvestigationBusinessActivity(
      floorLength: floorLength ?? this.floorLength,
      floorWidth: floorWidth ?? this.floorWidth,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
    );
  }

  @override
  List<Object?> get props => [floorLength, floorWidth, openingTime, closingTime];
}
