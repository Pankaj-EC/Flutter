import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class ApiService {
  String? _baseUrl;

  ApiService() {
    _initializeBaseUrl();
  }

  Future<void> _initializeBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('base_url') ?? 'http://10.0.2.2:3002'; // Default value
    print("URL"+_baseUrl!);
  }
  

  Future<String> getBaseUrl() async {
    if (_baseUrl == null) {
      await _initializeBaseUrl();
    }
    return _baseUrl!;
  }

  Future<List<Device>> getDevices() async {
    final baseUrl = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/getDevices'),
      body: jsonEncode({'device_ids': 'ALL'}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((device) => Device.fromJson(device)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<List<dynamic>> getDeviceData(String deviceId, int count) async {
    final baseUrl = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/getDevicesData'),
      body: jsonEncode({'device_id': deviceId, 'count': count}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load device data');
    }
  }

  Future<void> updateDevice(String deviceId, bool status) async {
    final baseUrl = await getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/updateDevice'),
      body: jsonEncode({'device_id': deviceId, 'status': status}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update device status');
    }
  }
}
