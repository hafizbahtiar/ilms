import 'package:equatable/equatable.dart';

class InvestigationSubmitResult extends Equatable {
  const InvestigationSubmitResult({required this.investigationNo, this.pendingPhotoUploads = 0});

  final String investigationNo;
  final int pendingPhotoUploads;

  @override
  List<Object?> get props => [investigationNo, pendingPhotoUploads];
}
