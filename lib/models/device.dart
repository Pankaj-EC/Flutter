class Device {
  final String deviceId;
  final DateTime creationTime;
  final bool status;

  Device({required this.deviceId, required this.creationTime, required this.status});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['device_ID'],
      creationTime: DateTime.parse(json['creation_Time']),
      status: json['status'],
    );
  }
}