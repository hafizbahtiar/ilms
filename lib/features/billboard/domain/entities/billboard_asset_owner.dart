import 'package:equatable/equatable.dart';

/// Owner of the physical structure (legacy `AssetOwnerDetails`) — a single
/// lookup dropdown, distinct from [BillboardMediaOwner].
class BillboardAssetOwner extends Equatable {
  const BillboardAssetOwner({this.code, this.desc});

  final String? code;
  final String? desc;

  BillboardAssetOwner copyWith({String? code, String? desc}) {
    return BillboardAssetOwner(code: code ?? this.code, desc: desc ?? this.desc);
  }

  @override
  List<Object?> get props => [code, desc];
}
