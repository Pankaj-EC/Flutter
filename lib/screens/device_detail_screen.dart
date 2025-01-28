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
  int dataCount = 10; // Initial count for data
  List<dynamic> deviceData = []; // Store device data

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
        deviceData = data; // Update the device data
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateDeviceStatus() async {
    try {
      await ApiService().updateDevice(widget.device.deviceId, status!);
      setState(() {
        fetchDeviceData(); // Refresh data after update
      });
    } catch (e) {
      // Handle error
    }
  }

  void loadMoreData() {
    setState(() {
      dataCount += 10; // Increase count by 10
      fetchDeviceData(); // Fetch more data
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Device ID: ${widget.device.deviceId}'),
                Switch(
                  value: status!,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                      updateDeviceStatus();
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: deviceData.isNotEmpty
                  ? Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('On Time')),
                                DataColumn(label: Text('Battery On')),
                                DataColumn(label: Text('Off Time')),
                                DataColumn(label: Text('Battery Off')),
                                DataColumn(label: Text('SV 9 AM')),
                                DataColumn(label: Text('SV 12 PM')),
                                DataColumn(label: Text('SV 3 PM')),
                                DataColumn(label: Text('SV 6 PM')),
                              ],
                              rows: deviceData.map((data) {
                                return DataRow(cells: [
                                  DataCell(Text(data['date'].split('T')[0])),
                                  DataCell(Text(data['on_Time'])),
                                  DataCell(
                                      Text(data['battery_Von'].toString())),
                                  DataCell(Text(data['off_Time'])),
                                  DataCell(
                                      Text(data['battery_Voff'].toString())),
                                  DataCell(Text(data['SV9AM'].toString())),
                                  DataCell(Text(data['SV12PM'].toString())),
                                  DataCell(Text(data['SV3PM'].toString())),
                                  DataCell(Text(data['SV6PM'].toString())),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: loadMoreData,
                          child: const Text('Load More'),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.warning, size: 50, color: Colors.red),
                          SizedBox(height: 10),
                          Text(
                            '📅 No Data Available',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('Please check back later.'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
