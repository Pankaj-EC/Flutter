import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;
  final Function(bool) onStatusChanged;

  const DeviceDetailScreen({
    Key? key,
    required this.device,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  bool? status;
  int dataCount = 10;
  List<dynamic> deviceData = [];
  bool isLoading = false;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    status = widget.device.status;
    fetchDeviceData();

    // Synchronize horizontal scroll controllers
    _horizontalController.addListener(() {
      _headerScrollController.jumpTo(_horizontalController.offset);
    });

    _headerScrollController.addListener(() {
      _horizontalController.jumpTo(_headerScrollController.offset);
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  Future<void> fetchDeviceData() async {
    try {
      setState(() => isLoading = true);
      final data =
          await ApiService().getDeviceData(widget.device.deviceId, dataCount);
      setState(() {
        deviceData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch device data: ${e.toString()}')),
      );
    }
  }

  Future<void> handleStatusChange(bool newStatus) async {
    try {
      setState(() => status = newStatus);
      await widget.onStatusChanged(newStatus);
      await fetchDeviceData(); // Refresh data after status change
    } catch (e) {
      // If the status change fails, revert the switch
      setState(() => status = !newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: ${e.toString()}')),
      );
    }
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.devices, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Device ID: ${widget.device.deviceId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status! ? Colors.green[50] : Colors.red[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          color: status! ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status! ? 'Device is Active' : 'Device is Inactive',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status! ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: status!,
                  onChanged: handleStatusChange,
                  activeColor: Colors.green[700],
                  activeTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.red[700],
                  inactiveTrackColor: Colors.red[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Headers with synchronized scroll
          Container(
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              controller: _headerScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: const [
                  _HeaderCell('📅 Date', width: 130),
                  _HeaderCell('⏰ On Time', width: 110),
                  _HeaderCell('🔋 Battery On', width: 110),
                  _HeaderCell('⏰ Off Time', width: 110),
                  _HeaderCell('🔋 Battery Off', width: 110),
                  _HeaderCell('📊 SV 9 AM', width: 110),
                  _HeaderCell('📊 SV 12 PM', width: 110),
                  _HeaderCell('📊 SV 3 PM', width: 110),
                  _HeaderCell('📊 SV 6 PM', width: 110),
                ],
              ),
            ),
          ),
          // Data rows with synchronized scroll
          Expanded(
            child: SingleChildScrollView(
              controller: _verticalController,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: deviceData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return Container(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.grey[50] : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _DataCell(
                            data['date'].split('T')[0],
                            width: 130,
                            isDate: true,
                            icon: Icons.calendar_today,
                          ),
                          _DataCell(
                            data['on_Time'],
                            width: 110,
                            isTime: true,
                            icon: Icons.access_time,
                            color: Colors.green[700],
                          ),
                          _DataCell(
                            '${data['battery_Von']}V',
                            width: 110,
                            isBattery: true,
                            icon: Icons.battery_charging_full,
                            color: Colors.blue[700],
                          ),
                          _DataCell(
                            data['off_Time'],
                            width: 110,
                            isTime: true,
                            icon: Icons.access_time_filled,
                            color: Colors.orange[700],
                          ),
                          _DataCell(
                            '${data['battery_Voff']}V',
                            width: 110,
                            isBattery: true,
                            icon: Icons.battery_alert,
                            color: Colors.red[700],
                          ),
                          _DataCell(
                            data['SV9AM'].toString(),
                            width: 110,
                            icon: Icons.show_chart,
                            color: Colors.purple[700],
                          ),
                          _DataCell(
                            data['SV12PM'].toString(),
                            width: 110,
                            icon: Icons.show_chart,
                            color: Colors.purple[700],
                          ),
                          _DataCell(
                            data['SV3PM'].toString(),
                            width: 110,
                            icon: Icons.show_chart,
                            color: Colors.purple[700],
                          ),
                          _DataCell(
                            data['SV6PM'].toString(),
                            width: 110,
                            icon: Icons.show_chart,
                            color: Colors.purple[700],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (deviceData.length % 10 == 0 && deviceData.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() {
                          dataCount += 10;
                        });
                        fetchDeviceData();
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: Text(isLoading ? 'Loading...' : 'Load More Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
        title: const Text('Device Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : fetchDeviceData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusCard(),
          Expanded(
            child: deviceData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_rounded,
                            size: 64, color: Colors.orange[300]),
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
                  )
                : _buildDataTable(),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const _HeaderCell(this.text, {required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.green[600]!, width: 0.5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isDate;
  final bool isTime;
  final bool isBattery;
  final IconData? icon;
  final Color? color;

  const _DataCell(
    this.text, {
    required this.width,
    this.isDate = false,
    this.isTime = false,
    this.isBattery = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: color ?? Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.grey[800],
              fontSize: 13,
              fontWeight: isDate || isTime || isBattery
                  ? FontWeight.w500
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
