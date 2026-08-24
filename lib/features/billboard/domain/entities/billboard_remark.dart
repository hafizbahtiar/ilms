import 'package:equatable/equatable.dart';

/// Multi-select remark codes with an optional "Others" free-text follow-up
/// (legacy `RemarksDetails`). Encode/decode against the legacy comma-joined
/// string via `billboard_remark_codec.dart`.
class BillboardRemark extends Equatable {
  const BillboardRemark({this.codes = const [], this.otherText});

  final List<String> codes;
  final String? otherText;

  BillboardRemark copyWith({List<String>? codes, String? otherText, bool clearOtherText = false}) {
    return BillboardRemark(
      codes: codes ?? this.codes,
      otherText: clearOtherText ? null : (otherText ?? this.otherText),
    );
  }

  @override
  List<Object?> get props => [codes, otherText];
}
