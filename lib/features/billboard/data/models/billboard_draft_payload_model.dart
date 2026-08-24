/// Serializable snapshot of billboard form presentation state for local
/// drafts — mirrors `premise_draft_payload_model.dart`'s shape.
class BillboardDraftPayloadModel {
  const BillboardDraftPayloadModel({
    this.fields = const {},
    this.isLedBoard = false,
    this.isLight = false,
    this.isPotential = false,
    this.parliamentCode,
    this.areaCode,
    this.assetOwnerCode,
    this.latitude,
    this.longitude,
    this.remarkCodes = const [],
    this.faces = const [],
    this.photos = const [],
  });

  final Map<String, String> fields;
  final bool isLedBoard;
  final bool isLight;
  final bool isPotential;
  final String? parliamentCode;
  final String? areaCode;
  final String? assetOwnerCode;
  final String? latitude;
  final String? longitude;
  final List<String> remarkCodes;
  final List<BillboardDraftFace> faces;
  final List<BillboardDraftPhoto> photos;

  Map<String, dynamic> toJson() => {
    'fields': fields,
    'isLedBoard': isLedBoard,
    'isLight': isLight,
    'isPotential': isPotential,
    'parliamentCode': parliamentCode,
    'areaCode': areaCode,
    'assetOwnerCode': assetOwnerCode,
    'latitude': latitude,
    'longitude': longitude,
    'remarkCodes': remarkCodes,
    'faces': faces.map((f) => f.toJson()).toList(),
    'photos': photos.map((p) => p.toJson()).toList(),
  };

  factory BillboardDraftPayloadModel.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'];
    final rawFaces = json['faces'];
    final rawPhotos = json['photos'];
    final rawRemarkCodes = json['remarkCodes'];

    return BillboardDraftPayloadModel(
      fields: rawFields is Map ? rawFields.map((key, value) => MapEntry('$key', '$value')) : const {},
      isLedBoard: json['isLedBoard'] == true,
      isLight: json['isLight'] == true,
      isPotential: json['isPotential'] == true,
      parliamentCode: json['parliamentCode'] as String?,
      areaCode: json['areaCode'] as String?,
      assetOwnerCode: json['assetOwnerCode'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      remarkCodes: rawRemarkCodes is List ? rawRemarkCodes.map((e) => '$e').toList() : const [],
      faces: rawFaces is List
          ? rawFaces
                .whereType<Map>()
                .map((item) => BillboardDraftFace.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
      photos: rawPhotos is List
          ? rawPhotos
                .whereType<Map>()
                .map((item) => BillboardDraftPhoto.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
    );
  }
}

class BillboardDraftFace {
  const BillboardDraftFace({this.id, this.localId, this.width, this.height, this.count});

  final int? id;
  final int? localId;
  final int? width;
  final int? height;
  final int? count;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (localId != null) 'localId': localId,
    'width': width,
    'height': height,
    'count': count,
  };

  factory BillboardDraftFace.fromJson(Map<String, dynamic> json) {
    return BillboardDraftFace(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      width: json['width'] is int ? json['width'] as int : int.tryParse('${json['width']}'),
      height: json['height'] is int ? json['height'] as int : int.tryParse('${json['height']}'),
      count: json['count'] is int ? json['count'] as int : int.tryParse('${json['count']}'),
    );
  }
}

class BillboardDraftPhoto {
  const BillboardDraftPhoto({this.id, this.localId, this.localPath, this.networkUrl, this.uploadStatus = 'local'});

  final int? id;
  final int? localId;
  final String? localPath;
  final String? networkUrl;
  final String uploadStatus;

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (localId != null) 'localId': localId,
    'localPath': localPath,
    'networkUrl': networkUrl,
    'uploadStatus': uploadStatus,
  };

  factory BillboardDraftPhoto.fromJson(Map<String, dynamic> json) {
    return BillboardDraftPhoto(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      localId: json['localId'] is int ? json['localId'] as int : int.tryParse('${json['localId']}'),
      localPath: json['localPath'] as String?,
      networkUrl: json['networkUrl'] as String?,
      uploadStatus: json['uploadStatus'] as String? ?? 'local',
    );
  }
}
