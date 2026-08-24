import 'package:equatable/equatable.dart';

/// One physical panel of the billboard (legacy `Face`) — dimensions in
/// millimeters. Repeatable list, add/edit/delete via `BillboardFaceDialog`.
class BillboardFace extends Equatable {
  const BillboardFace({this.id, this.localId, this.width, this.height, this.count});

  final int? id;
  final int? localId;
  final int? width;
  final int? height;
  final int? count;

  BillboardFace copyWith({int? id, int? localId, int? width, int? height, int? count}) {
    return BillboardFace(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      width: width ?? this.width,
      height: height ?? this.height,
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [id, localId, width, height, count];
}
