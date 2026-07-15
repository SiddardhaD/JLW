enum Flavor { dev, staging, prod }

/// Holds the environment (dev/staging/prod) the app was launched with.
/// Set once from `main_dev.dart` / `main_staging.dart` / `main_prod.dart`
/// before `runApp`, then read anywhere via [FlavorConfig.instance].
class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String baseUrl;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String baseUrl,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor: flavor,
      name: _nameFor(flavor),
      baseUrl: baseUrl,
    );
    return _instance!;
  }

  FlavorConfig._internal({
    required this.flavor,
    required this.name,
    required this.baseUrl,
  });

  static FlavorConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'FlavorConfig has not been initialized. Call FlavorConfig(flavor: ..., baseUrl: ...) '
        'from main_dev.dart / main_staging.dart / main_prod.dart before runApp().',
      );
    }
    return config;
  }

  static bool get isDev => instance.flavor == Flavor.dev;
  static bool get isStaging => instance.flavor == Flavor.staging;
  static bool get isProd => instance.flavor == Flavor.prod;

  static String _nameFor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return 'Dev';
      case Flavor.staging:
        return 'Staging';
      case Flavor.prod:
        return 'Prod';
    }
  }
}
