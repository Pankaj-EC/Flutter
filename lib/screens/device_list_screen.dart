import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/device.dart';
import 'device_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

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
    refreshDeviceList();
    _loadPinnedDevice();
  }

  Future<void> refreshDeviceList() async {
    setState(() {
      futureDevices = ApiService().getDevices();
    });
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

  Future<void> togglePin(String deviceId) async {
    if (pinnedDeviceId == deviceId) {
      setState(() {
        pinnedDeviceData = null;
        pinnedDeviceId = null;
      });
      await _savePinnedDevice(null);
    } else {
      try {
        final data = await ApiService().getDeviceData(deviceId, 1);
        if (data.isNotEmpty) {
          setState(() {
            pinnedDeviceData = data[0];
            pinnedDeviceId = deviceId;
          });
          await _savePinnedDevice(deviceId);
        } else {
          _showNoDataDialog();
        }
      } catch (e) {
        _showNoDataDialog();
      }
    }
  }

  void _showNoDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange[400], size: 28),
            const SizedBox(width: 8),
            const Text('No Data Available'),
          ],
        ),
        content: const Text(
          'There is no data available for this device at the moment. Please try again later.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateDeviceStatus(String deviceId, bool newStatus) async {
    try {
      await ApiService().updateDevice(deviceId, newStatus);
      // Refresh both the device list and pinned device data
      refreshDeviceList();
      if (pinnedDeviceId == deviceId) {
        await fetchPinnedDeviceData(deviceId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update device status: ${e.toString()}')),
      );
    }
  }

  Widget _buildStatusIndicator(bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: status ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 4),
          Text(
            status ? 'Active' : 'Inactive',
            style: TextStyle(
              color: status ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device, bool isPinned) {
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
            const SizedBox(height: 8),
            Text(
              'Created on: ${device.creationTime}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            _buildStatusIndicator(device.status),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: isPinned ? Colors.green[700] : Colors.grey,
              ),
              onPressed: () => togglePin(device.deviceId),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(
                device: device,
                onStatusChanged: (newStatus) async {
                  await updateDeviceStatus(device.deviceId, newStatus);
                  refreshDeviceList(); // Refresh the list after status change
                },
              ),
            ),
          );
          if (result == true) {
            refreshDeviceList();
          }
        },
      ),
    );
  }

  Future<void> refreshAllData() async {
    try {
      // Refresh pinned device data if exists
      if (pinnedDeviceId != null) {
        await fetchPinnedDeviceData(pinnedDeviceId!);
      }
      // Refresh device list
      await refreshDeviceList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh data: ${e.toString()}')),
      );
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
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
              'Pin a device to see quick insights',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      );
    }

    final date = DateTime.parse(pinnedDeviceData!['date']).toLocal();
    final formattedDate = "${date.day}/${date.month}/${date.year}";

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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                Expanded(
                  child: Row(
                    children: [
                      // const Icon(Icons.devices, color: Colors.white),
                      // const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Device ID: ${pinnedDeviceId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => fetchPinnedDeviceData(pinnedDeviceId!),
                      tooltip: 'Refresh Data',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => togglePin(pinnedDeviceId!),
                      tooltip: 'Unpin Device',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Data for $formattedDate',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDataCard(
                        'Time Details',
                        [
                          _buildDataRow('On Time', pinnedDeviceData!['on_Time'],
                              Icons.access_time),
                          _buildDataRow(
                              'Off Time',
                              pinnedDeviceData!['off_Time'],
                              Icons.access_time_filled),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDataCard(
                        'Battery Status',
                        [
                          _buildDataRow(
                              'Battery On',
                              '${pinnedDeviceData!['battery_Von']}V',
                              Icons.battery_charging_full),
                          _buildDataRow(
                              'Battery Off',
                              '${pinnedDeviceData!['battery_Voff']}V',
                              Icons.battery_alert),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSolarVoltageCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          ...content,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolarVoltageCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.solar_power, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Solar Voltage Readings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildSolarReadingTile('9:00 AM',
                        '${pinnedDeviceData!['SV9AM'].toString()}V'), //'${pinnedDeviceData!['battery_Von']}V'
                    const SizedBox(height: 12),
                    _buildSolarReadingTile('12:00 PM',
                        '${pinnedDeviceData!['SV12PM'].toString()}V'), //'${pinnedDeviceData!['battery_Von']}V'
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildSolarReadingTile(
                        '3:00 PM', '${pinnedDeviceData!['SV3PM'].toString()}V'),
                    const SizedBox(height: 12),
                    _buildSolarReadingTile(
                        '6:00 PM', '${pinnedDeviceData!['SV6PM'].toString()}V'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolarReadingTile(String time, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
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
        leading: null,
        title: Row(
          children: [
            const Icon(
              Icons.solar_power,
              size: 28,
              color: Color.fromARGB(255, 241, 180, 12),
            ),
            const SizedBox(width: 8),
            const Text(
              'SOLAR IOT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 28,
              color: Colors.white,
            ),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: null,
      body: RefreshIndicator(
        onRefresh: refreshAllData,
        child: Column(
          children: [
            buildPinnedDeviceTile(),
            Expanded(
              child: FutureBuilder<List<Device>>(
                future: futureDevices,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading devices: ${snapshot.error}',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No devices found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  final devices = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      if (index >= devices.length) {
                        return null;
                      }
                      final device = devices[index];
                      return _buildDeviceCard(
                        device,
                        pinnedDeviceId == device.deviceId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
