/// Lifecycle / availability state for [AppCameraService].
enum CameraStatus {
  uninitialized,
  initializing,
  ready,
  permissionDenied,
  permissionDeniedForever,
  error,
}
