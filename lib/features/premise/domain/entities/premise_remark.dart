import 'package:equatable/equatable.dart';

class PremiseRemark extends Equatable {
  const PremiseRemark({this.id, this.localId, this.remark, this.createdAt});

  final int? id;
  final int? localId;
  final String? remark;
  final String? createdAt;

  @override
  List<Object?> get props => [id, localId, remark, createdAt];
}
