import 'dart:async'; // Import this for TimeoutException
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this dependency
import '../models/device.dart';

class ApiService {
  String? _baseUrl;

  ApiService() {
    _initializeBaseUrl();
  }

  Future<void> _initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('base_url') ?? 'https://solar-iot-be.vercel.app'; // Default value
    print("Base URL: $_baseUrl");
  }

  Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await _initializeBaseUrl();
    }
    return _baseUrl!;
  }

  // Method to check if device has internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      var result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Helper method for sending HTTP requests with a timeout
  Future<http.Response> _sendRequest(Uri uri, String body) async {
    final client = http.Client();
    try {
      // Add retry mechanism
      int maxRetries = 3;
      int currentTry = 0;
      
      while (currentTry < maxRetries) {
        try {
          final response = await client.post(
            uri,
            body: body,
            headers: {
              'Content-Type': 'application/json',
              'Connection': 'keep-alive',
            },
          ).timeout(const Duration(seconds: 15));

          return response;
        } catch (e) {
          currentTry++;
          if (currentTry == maxRetries) rethrow;
          // Wait before retrying
          await Future.delayed(Duration(seconds: currentTry));
        }
      }
      throw Exception('Failed after $maxRetries retries');
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is TimeoutException) {
        throw Exception('Request timed out: Please try again');
      } else {
        throw Exception('Error: ${e.toString()}');
      }
    } finally {
      client.close();
    }
  }

  Future<List<Device>> getDevices() async {
    final baseUrl = await getBaseUrl();

    // Check for internet connection before proceeding
    if (!await _hasInternetConnection()) {
      throw Exception('No internet connection available');
    }

    try {
      final response = await _sendRequest(
        Uri.parse('$baseUrl/getDevices'),
        jsonEncode({'device_ids': 'ALL'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((device) => Device.fromJson(device)).toList();
      } else {
        throw Exception('Failed to load devices, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading devices: $e');
    }
  }

  Future<List<dynamic>> getDeviceData(String deviceId, int count) async {
    final baseUrl = await getBaseUrl();

    // Check for internet connection before proceeding
    if (!await _hasInternetConnection()) {
      throw Exception('No internet connection available');
    }

    try {
      final response = await _sendRequest(
        Uri.parse('$baseUrl/getDevicesData'),
        jsonEncode({'device_id': deviceId, 'count': count}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load device data, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading device data: $e');
    }
  }

  Future<void> updateDevice(String deviceId, bool status) async {
    final baseUrl = await getBaseUrl();

    // Check for internet connection before proceeding
    if (!await _hasInternetConnection()) {
      throw Exception('No internet connection available');
    }

    try {
      final response = await _sendRequest(
        Uri.parse('$baseUrl/updateDevice'),
        jsonEncode({'device_id': deviceId, 'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update device status, Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating device status: $e');
    }
  }
}
