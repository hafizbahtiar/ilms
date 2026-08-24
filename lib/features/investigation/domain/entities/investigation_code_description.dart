import 'package:equatable/equatable.dart';

/// Shared code/description pair — used for applicant business types and
/// advertisement types.
class InvestigationCodeDescription extends Equatable {
  const InvestigationCodeDescription({this.code, this.description});

  final String? code;
  final String? description;

  @override
  List<Object?> get props => [code, description];
}
