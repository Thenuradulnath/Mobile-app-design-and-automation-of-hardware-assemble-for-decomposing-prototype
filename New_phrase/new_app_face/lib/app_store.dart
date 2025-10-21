import 'package:flutter/foundation.dart';

/// Global bottom-nav index so any page can switch tabs.
class AppNav {
  static final ValueNotifier<int> index = ValueNotifier(0);
}

/// Cross-page demo state for Home summaries.
class AppStore {
  // Sensors summary
  static int sensorsTotal = 0;
  static int sensorsOnline = 0;
  static int sensorsAlerts = 0;
  static void setSensorsSummary({
    required int total,
    required int online,
    required int alerts,
  }) {
    sensorsTotal = total;
    sensorsOnline = online;
    sensorsAlerts = alerts;
  }

  // Calculation
  static double? lastCN;
  static List<String> lastRecommendations = [];

  // 3D
  static bool modelLoaded = false;
}
