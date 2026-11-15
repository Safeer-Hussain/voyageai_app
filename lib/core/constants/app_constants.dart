class AppConstants {
  static const String appName = 'VoyageAI';
  static const String appVersion = '1.0.0+1';
  static const String appBuild = 'Enterprise Edition';

  // Platform Channels
  static const String navigationSensorsChannel =
      'com.safeer.voyageai/navigation_sensors';
  static const String expeditionTelemetryChannel =
      'com.safeer.voyageai/expedition_telemetry';

  // Storage Keys
  static const String keyActiveTripId = 'voyage_active_trip_id';
  static const String keyThemeMode = 'voyage_theme_mode';
  static const String keyBaseCurrency = 'voyage_base_currency';
  static const String keySimulatedLatencyMs = 'voyage_simulated_latency_ms';
  static const String keyForce503Errors = 'voyage_force_503_errors';
  static const String keyOfflineSimulated = 'voyage_offline_simulated';

  // Currencies
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = [
    'USD',
    'PKR',
    'EUR',
    'JPY',
    'AED',
  ];

  // Base Exchange Rates to USD
  static const Map<String, double> usdExchangeRates = {
    'USD': 1.0,
    'PKR': 278.50,
    'EUR': 0.92,
    'JPY': 154.20,
    'AED': 3.67,
  };
}
