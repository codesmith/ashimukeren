import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static Map<String, dynamic>? _config;

  static Future<void> loadConfig() async {
    if (_config == null) {
      final String configString = await rootBundle.loadString('assets/config/dev.json');
      _config = json.decode(configString);
    }
  }

  static String? getGoogleMapsApiKey() {
    return _config?['GOOGLE_MAPS_API_KEY'];
  }
}