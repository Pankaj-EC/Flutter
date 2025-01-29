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
    try {
      final response = await http.post(
        uri,
        body: body,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // Add timeout to avoid indefinite waiting

      return response;
    } on TimeoutException catch (_) {
      throw Exception('Request timed out');
    } on SocketException catch (_) {
      throw Exception('No internet connection');
    } on HttpException catch (_) {
      throw Exception('Failed to load data from the server');
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
