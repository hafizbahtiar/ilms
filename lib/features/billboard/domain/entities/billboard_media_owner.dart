import 'package:equatable/equatable.dart';

/// The media company operating the billboard (legacy `MediaOwnerDetails`).
class BillboardMediaOwner extends Equatable {
  const BillboardMediaOwner({this.name, this.tel});

  final String? name;
  final String? tel;

  BillboardMediaOwner copyWith({String? name, String? tel}) {
    return BillboardMediaOwner(name: name ?? this.name, tel: tel ?? this.tel);
  }

  @override
  List<Object?> get props => [name, tel];
}
