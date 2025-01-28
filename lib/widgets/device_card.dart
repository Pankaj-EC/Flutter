import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceCard extends StatefulWidget {
  final Device device;
  final bool isDarkMode;

  const DeviceCard({super.key, required this.device, required this.isDarkMode});

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool isExpanded = false;
  bool? status;

  @override
  void initState() {
    super.initState();
    status = widget.device.status;
  }

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Future<void> updateDeviceStatus() async {
    try {
      await ApiService().updateDevice(widget.device.deviceId, status!);
      // Optionally refresh the device list or show a success message
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: widget.isDarkMode ? Colors.grey[850] : Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text('Device ID: ${widget.device.deviceId}'),
            subtitle: Text('Created on: ${widget.device.creationTime}'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: toggleExpand,
            ),
          ),
          if (isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Last Day Data:'),
                  // Display last day data here (you can fetch it from the API)
                  // For example, you can call /deviceData with count 10
                  // and display the results in a ListView or similar widget
                  // Placeholder for last day data
                  const Text('Data for last day: ...'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status: ${status == true ? "Active" : "Inactive"}'),
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
