sealed class InvestigationException implements Exception {
  const InvestigationException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class InvestigationSearchException extends InvestigationException {
  const InvestigationSearchException(super.message);
}

final class InvestigationDetailException extends InvestigationException {
  const InvestigationDetailException(super.message);
}

final class InvestigationSubmitException extends InvestigationException {
  const InvestigationSubmitException(super.message);
}

final class InvestigationPhotoUploadException extends InvestigationException {
  const InvestigationPhotoUploadException(super.message);
}
