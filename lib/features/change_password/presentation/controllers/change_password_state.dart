class ChangePasswordState {
  const ChangePasswordState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  ChangePasswordState copyWith({bool? isLoading, String? errorMessage, bool clearError = false}) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
