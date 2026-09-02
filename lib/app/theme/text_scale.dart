enum AppTextScale { small, medium, large, extraLarge }

const _textScaleOptions = [AppTextScale.small, AppTextScale.medium, AppTextScale.large, AppTextScale.extraLarge];

List<AppTextScale> textScaleOptions() => _textScaleOptions;

double appTextScaleFactor(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.small:
      return 0.85;
    case AppTextScale.medium:
      return 1.0;
    case AppTextScale.large:
      return 1.15;
    case AppTextScale.extraLarge:
      return 1.30;
  }
}

String textScaleLabel(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.small:
      return 'Small';
    case AppTextScale.medium:
      return 'Default';
    case AppTextScale.large:
      return 'Large';
    case AppTextScale.extraLarge:
      return 'Extra Large';
  }
}

String? textScaleStorageKey(AppTextScale scale) {
  switch (scale) {
    case AppTextScale.medium:
      return null;
    case AppTextScale.small:
      return 'small';
    case AppTextScale.large:
      return 'large';
    case AppTextScale.extraLarge:
      return 'extra_large';
  }
}

AppTextScale appTextScaleFromStorage(String? value) {
  switch (value) {
    case 'small':
      return AppTextScale.small;
    case 'large':
      return AppTextScale.large;
    case 'extra_large':
      return AppTextScale.extraLarge;
    default:
      return AppTextScale.medium;
  }
}
