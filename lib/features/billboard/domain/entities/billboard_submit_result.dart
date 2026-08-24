import 'package:equatable/equatable.dart';

class BillboardSubmitResult extends Equatable {
  const BillboardSubmitResult({required this.billboardNo, this.updatedAt, this.pendingImageUploads = 0});

  final String billboardNo;
  final String? updatedAt;
  final int pendingImageUploads;

  @override
  List<Object?> get props => [billboardNo, updatedAt, pendingImageUploads];
}
