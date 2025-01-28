import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool? status;
  late Future<List<dynamic>> futureDeviceData;
  int dataCount = 10;
  List<dynamic> deviceData = [];

  @override
  void initState() {
    super.initState();
    status = widget.device.status;
    fetchDeviceData();
  }

  Future<void> fetchDeviceData() async {
    try {
      final data =
          await ApiService().getDeviceData(widget.device.deviceId, dataCount);
      setState(() {
        deviceData = data;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateDeviceStatus() async {
    try {
      await ApiService().updateDevice(widget.device.deviceId, status!);
      setState(() {
        fetchDeviceData();
      });
    } catch (e) {
      // Handle error
    }
  }

  void loadMoreData() {
    setState(() {
      dataCount += 10;
      fetchDeviceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Device Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device ID: ${widget.device.deviceId}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${status! ? "Active" : "Inactive"}',
                      style: TextStyle(
                        color: status! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: status!,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                      updateDeviceStatus();
                    });
                  },
                ),
              ],
            ),
          ),

          // Data Table Section
          Expanded(
            child: deviceData.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.grey[100],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'On Time',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Battery On',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Off Time',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Battery Off',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SV 9 AM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SV 12 PM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SV 3 PM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SV 6 PM',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                rows: deviceData.map((data) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(data['date'].split('T')[0])),
                                      DataCell(Text(data['on_Time'])),
                                      DataCell(
                                          Text(data['battery_Von'].toString())),
                                      DataCell(Text(data['off_Time'])),
                                      DataCell(Text(
                                          data['battery_Voff'].toString())),
                                      DataCell(Text(data['SV9AM'].toString())),
                                      DataCell(Text(data['SV12PM'].toString())),
                                      DataCell(Text(data['SV3PM'].toString())),
                                      DataCell(Text(data['SV6PM'].toString())),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        if (deviceData.length ==
                            10) // Show Load More button only if data size is 10
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton.icon(
                              onPressed: loadMoreData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Load More Data'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 64,
                          color: Colors.orange[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '📅 No Data Available',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please check back later',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
