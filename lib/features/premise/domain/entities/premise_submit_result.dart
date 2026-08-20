import 'package:equatable/equatable.dart';

class PremiseSubmitResult extends Equatable {
  const PremiseSubmitResult({required this.visitNo, this.updatedAt, this.pendingImageUploads = 0});

  final String visitNo;
  final String? updatedAt;
  final int pendingImageUploads;

  @override
  List<Object?> get props => [visitNo, updatedAt, pendingImageUploads];
}
