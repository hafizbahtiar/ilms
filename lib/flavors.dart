const appFlavor = String.fromEnvironment('APP_FLAVOR');

enum Flavor { dev, stg, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'ILMS Dev';
      case Flavor.stg:
        return 'ILMS Stg';
      case Flavor.prod:
        return 'ILMS';
    }
  }
}
