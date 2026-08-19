enum AppFlavor {
  dev,
  stg,
  prod;

  static AppFlavor fromName(String? name) {
    for (final flavor in AppFlavor.values) {
      if (flavor.name == name) {
        return flavor;
      }
    }
    return AppFlavor.dev;
  }
}
