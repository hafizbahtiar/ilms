sealed class PremiseException implements Exception {
  const PremiseException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class PremiseSubmitException extends PremiseException {
  const PremiseSubmitException(super.message);
}

final class PremiseImageUploadException extends PremiseException {
  const PremiseImageUploadException(super.message);
}
