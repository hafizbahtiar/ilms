import 'package:equatable/equatable.dart';

class PremiseRemark extends Equatable {
  const PremiseRemark({
    this.id,
    this.localId,
    this.code,
    this.remark,
    this.remarkType,
    this.remarkDesc,
    this.description,
    this.createdAt,
  });

  final int? id;
  final int? localId;
  final String? code;
  final String? remark;
  final String? remarkType;
  final String? remarkDesc;
  final String? description;
  final String? createdAt;

  bool get isOther => (remark ?? '').toLowerCase() == 'other';

  PremiseRemark copyWith({
    int? id,
    int? localId,
    String? code,
    String? remark,
    String? remarkType,
    String? remarkDesc,
    String? description,
    String? createdAt,
  }) {
    return PremiseRemark(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      code: code ?? this.code,
      remark: remark ?? this.remark,
      remarkType: remarkType ?? this.remarkType,
      remarkDesc: remarkDesc ?? this.remarkDesc,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, localId, code, remark, remarkType, remarkDesc, description, createdAt];
}
