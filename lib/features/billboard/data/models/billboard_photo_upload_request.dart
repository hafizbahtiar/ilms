import 'dart:typed_data';

/// Multipart body for `POST /api/billboardCensus/create-photo`.
///
/// Matches the working premise/investigation create-photo shape
/// (`{id, process, images[0]{type, seq, file}}`), with `billboard_no` as the
/// record identifier. The unused legacy `CreateBillboardPhotoInput` sent the
/// number under `photo_url`, which the API rejects as
/// "The billboard number is required".
class BillboardPhotoUploadRequest {
  BillboardPhotoUploadRequest._();

  static Map<String, dynamic> toMap({
    required String billboardNo,
    required Uint8List file,
    String process = 'create',
    int seq = 1,
  }) {
    return {
      'billboard_no': billboardNo,
      'process': process,
      'images': <Map<String, dynamic>>[
        {'type': '', 'seq': seq, 'file': file},
      ],
    };
  }
}
