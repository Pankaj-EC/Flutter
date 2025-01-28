import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class ApiService {
  // Use the appropriate IP address based on your testing environment
  final String baseUrl = 'http://10.0.2.2:3002'; // For Android Emulator
  // final String baseUrl = 'http://192.168.x.x:3002'; // For Physical Device (replace with your machine's IP)
  // final String baseUrl = 'http://localhost:3002'; // For iOS Simulator

  Future<List<Device>> getDevices() async {
    final response = await http.post(Uri.parse('$baseUrl/getDevices'),
        body: jsonEncode({'device_ids': 'ALL'}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((device) => Device.fromJson(device)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<List<dynamic>> getDeviceData(String deviceId, int count) async {
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
