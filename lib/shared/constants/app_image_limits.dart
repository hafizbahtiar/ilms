/// Shared image count limits used by form image fields across modules.
abstract final class AppImageLimits {
  static const int defaultMaxImages = 30;
}

/// Returns how many more images can still be added.
int remainingImageSlots({required int currentCount, int maxImages = AppImageLimits.defaultMaxImages}) {
  return (maxImages - currentCount).clamp(0, maxImages);
}

/// Whether another image can be added.
bool canAddMoreImages({required int currentCount, int maxImages = AppImageLimits.defaultMaxImages}) {
  return currentCount < maxImages;
}
