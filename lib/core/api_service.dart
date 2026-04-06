import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2/api'; // Standard Android Emulator localhost

  static Future<Map<String, dynamic>?> getFxRates() async {
    try {
      // In a real app, we might call an endpoint that returns all rates
      // For now, we'll try to use the calculate endpoint or a mock if it fails
      final response = await http.get(Uri.parse('$baseUrl/fx/calculate?amount=1'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching FX rates: $e');
    }
    return null;
  }

  // Generic method to fetch all active rates if the API supports it
  static Future<Map<String, double>> fetchAllRates() async {
    // This is a placeholder for a real API call that returns multiple rates
    // Since our backend calculateFxConversion only handles EUR/USD, 
    // we'll return a mix of API data and defaults for now.
    
    Map<String, double> defaultRates = {
      "USD": 1.0,
      "EUR": 0.93,
      "GBP": 0.79,
      "CAD": 1.35,
      "KES": 128.50,
      "SOS": 570.00,
      "AED": 3.67,
      "SAR": 3.75,
      "TRY": 32.20,
      "ETB": 57.50,
      "DJF": 177.72,
      "UGX": 3750.00,
      "TZS": 2600.00,
      "RWF": 1300.00,
      "SDG": 600.00,
      "EGP": 47.50,
      "INR": 83.30,
      "CNY": 7.24,
      "JPY": 156.00,
      "AUD": 1.51,
      "CHF": 0.91,
      "ZAR": 18.50,
    };

    try {
      final response = await http.get(Uri.parse('$baseUrl/fx/calculate?amount=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // If the API returns 1 EUR = X USD, then 1 USD = 1/X EUR
        double rate = data['rate'] ?? 1.12; // Example 1.12 USD for 1 EUR
        defaultRates['EUR'] = 1 / rate;
      }
    } catch (e) {
      print('Using fallback rates due to error: $e');
    }

    return defaultRates;
  }
}
