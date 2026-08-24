sealed class BillboardException implements Exception {
  const BillboardException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class BillboardSubmitException extends BillboardException {
  const BillboardSubmitException(super.message);
}

final class BillboardImageUploadException extends BillboardException {
  const BillboardImageUploadException(super.message);
}

final class BillboardImageDeleteException extends BillboardException {
  const BillboardImageDeleteException(super.message);
}
