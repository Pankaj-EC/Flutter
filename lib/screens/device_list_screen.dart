import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/device.dart';
import '../widgets/device_card.dart';
import 'device_detail_screen.dart'; // Import the new detail screen

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  late Future<List<Device>> futureDevices;

  @override
  void initState() {
    super.initState();
    futureDevices = ApiService().getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, size: 30, color: Colors.yellow),
                const SizedBox(width: 8),
                const Text('Solar Streetlight Tracker'),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Device>>(
        future: futureDevices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final devices = snapshot.data!;
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to the device detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeviceDetailScreen(device: devices[index]),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Device ID: ${devices[index].deviceId}'),
                      subtitle:
                          Text('Created on: ${devices[index].creationTime}'),
                      trailing: const Icon(
                          Icons.chevron_right), // Chevron icon for navigation
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
