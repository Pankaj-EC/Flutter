import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/device.dart';
import 'device_detail_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  late Future<List<Device>> futureDevices;
  Map<String, dynamic>? pinnedDeviceData;
  String? pinnedDeviceId;
  final String _pinnedDeviceKey = 'pinned_device_id';

  @override
  void initState() {
    super.initState();
    futureDevices = ApiService().getDevices();
    _loadPinnedDevice();
  }

  Future<void> _loadPinnedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeviceId = prefs.getString(_pinnedDeviceKey);
    if (savedDeviceId != null) {
      await fetchPinnedDeviceData(savedDeviceId);
    }
  }

  Future<void> _savePinnedDevice(String? deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    if (deviceId != null) {
      await prefs.setString(_pinnedDeviceKey, deviceId);
    } else {
      await prefs.remove(_pinnedDeviceKey);
    }
  }

  Future<void> fetchPinnedDeviceData(String deviceId) async {
    try {
      final data = await ApiService().getDeviceData(deviceId, 1);
      if (data.isNotEmpty) {
        setState(() {
          pinnedDeviceData = data[0];
          pinnedDeviceId = deviceId;
        });
        await _savePinnedDevice(deviceId);
      }
    } catch (e) {
      // Handle error
    }
  }

  void togglePin(String deviceId) async {
    if (pinnedDeviceId == deviceId) {
      // Unpin the device
      setState(() {
        pinnedDeviceData = null;
        pinnedDeviceId = null;
      });
      await _savePinnedDevice(null);
    } else {
      // Pin new device (this will automatically unpin the previous one)
      await fetchPinnedDeviceData(deviceId);
    }
  }

  Widget buildPinnedDeviceTile() {
    if (pinnedDeviceData == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.green[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.push_pin_outlined,
                  size: 32, color: Colors.green[700]),
            ),
            const SizedBox(height: 16),
            Text(
              '📌 No Device Pinned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pin a device from the list to see quick insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.push_pin, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Device: $pinnedDeviceId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 20),
                  onPressed: () {
                    if (pinnedDeviceId != null) {
                      fetchPinnedDeviceData(pinnedDeviceId!);
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard(
                      'Last Update',
                      pinnedDeviceData!['date'].split('T')[0],
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                    _buildMetricCard(
                      'Operation Hours',
                      '${pinnedDeviceData!['on_Time']} - ${pinnedDeviceData!['off_Time']}',
                      Icons.access_time,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCard(
                      'Battery On',
                      '${pinnedDeviceData!['battery_Von']}V',
                      Icons.battery_charging_full,
                      Colors.green,
                    ),
                    _buildMetricCard(
                      'Battery Off',
                      '${pinnedDeviceData!['battery_Voff']}V',
                      Icons.battery_alert,
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, MaterialColor color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color[700], size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.wb_sunny, size: 30, color: Colors.yellow),
            const SizedBox(width: 8),
            const Text('Solar Streetlight Tracker'),
          ],
        ),
      ),
      body: Column(
        children: [
          buildPinnedDeviceTile(),
          Expanded(
            child: FutureBuilder<List<Device>>(
              future: futureDevices,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final devices = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      final isPinned = device.deviceId == pinnedDeviceId;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Device ID: ${device.deviceId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Created on: ${device.creationTime}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${device.status ? "Active" : "Inactive"}',
                                style: TextStyle(
                                  color: device.status
                                      ? Colors.green[700]
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  color: isPinned
                                      ? Colors.green[700]
                                      : Colors.grey,
                                ),
                                onPressed: () => togglePin(device.deviceId),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DeviceDetailScreen(device: device),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
